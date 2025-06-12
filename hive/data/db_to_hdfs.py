import psycopg2
from hdfs import InsecureClient
import csv
import subprocess
import pandas as pd
import pyarrow as pa
from pyarrow import orc
from decimal import Decimal
def connect_to_postgres():
    try:
        conn = psycopg2.connect(
            host="db",
            port="5432",
            dbname="postgres",
            user="postgres",
            password="123"
        )
        print("Connection to PostgreSQL successful")
        return conn
    except Exception as e:
        print(f"Error: Unable to connect to the database. {e}")
        raise

def get_all_views(conn):
    try:
        cur = conn.cursor()
        cur.execute("""
            SELECT table_name 
            FROM information_schema.views 
            WHERE table_schema = 'public';
        """)
        views = [view[0] for view in cur.fetchall()]
        cur.close()
        return views
    except Exception as e:
        print(f"Error while fetching view list: {e}")
        raise

def fetch_data_from_view(conn, view_name):
    try:
        cur = conn.cursor()
        cur.execute(f"SELECT * FROM {view_name};")
        data = cur.fetchall()
        columns = [desc[0] for desc in cur.description]
        cur.close()
        return columns, data
    except Exception as e:
        print(f"Error while fetching data from view {view_name}: {e}")
        raise


def write_data_as_orc(data, columns, view_name):
    try:
        # Create a temporary local file
        local_file = f"/tmp/{view_name}.orc"
        
        # Convert to pandas DataFrame
        df = pd.DataFrame(data, columns=columns)
        
        # Custom type conversion for Decimal columns
        def decimal_to_float(val):
            if isinstance(val, Decimal):
                return float(val)
            return val
        
        # Apply decimal conversion to all columns that might contain decimals
        for col in df.columns:
            if df[col].apply(lambda x: isinstance(x, Decimal)).any():
                df[col] = df[col].apply(decimal_to_float)
        
        # Create PyArrow schema with explicit type handling
        schema_fields = []
        for col in df.columns:
            dtype = str(df[col].dtype)
            if dtype == 'object':
                # Check if it's actually a decimal column that we converted to float
                if df[col].apply(lambda x: isinstance(x, (float, int))).all():
                    schema_fields.append((col, pa.float64()))
                else:
                    schema_fields.append((col, pa.string()))
            elif dtype.startswith('int'):
                schema_fields.append((col, pa.int64()))
            elif dtype.startswith('float'):
                schema_fields.append((col, pa.float64()))
            elif dtype == 'bool':
                schema_fields.append((col, pa.bool_()))
            else:
                schema_fields.append((col, pa.string()))  # fallback
        
        schema = pa.schema(schema_fields)
        
        # Create table (empty if no data)
        if df.empty:
            print(f"View {view_name} is empty - writing schema-only ORC file")
            arrays = [pa.array([], type=field.type) for field in schema]
            table = pa.Table.from_arrays(arrays, schema=schema)
        else:
            # Convert each column to the correct Arrow array type
            arrays = []
            for col, field in zip(df.columns, schema):
                if pa.types.is_float64(field.type):
                    arrays.append(pa.array(df[col].astype('float64')))
                elif pa.types.is_int64(field.type):
                    arrays.append(pa.array(df[col].astype('int64')))
                else:
                    arrays.append(pa.array(df[col].astype('str')))
            table = pa.Table.from_arrays(arrays, schema=schema)
        
        # Write ORC file locally
        orc.write_table(table, local_file)
        
        # HDFS directory structure
        hdfs_view_dir = f"/user/hive/warehouse/views/{view_name}/"
        hdfs_file_path = f"{hdfs_view_dir}data.orc"
        
        # Clean up any existing directory
        subprocess.run(["hadoop", "fs", "-rm", "-r", "-f", hdfs_view_dir], check=False)
        
        # Create directory
        subprocess.run(["hadoop", "fs", "-mkdir", "-p", hdfs_view_dir], check=True)
        
        # Copy to HDFS
        subprocess.run(["hadoop", "fs", "-copyFromLocal", local_file, hdfs_file_path], check=True)
        
        # Clean up local file
        subprocess.run(["rm", "-f", local_file], check=True)
        
        print(f"Successfully wrote {view_name} to {hdfs_file_path}")
        return True
        
    except Exception as e:
        print(f"Error processing {view_name}: {str(e)}")
        return False

def insert_into_meta_data(conn, views_processed):
    try:
        cur = conn.cursor()
        cur.execute("""
            INSERT INTO public.meta_data (id)
            VALUES ((SELECT COALESCE(MAX(id), 0) + 1 FROM public.meta_data));
        """, (views_processed,))
        conn.commit()
        print("Successfully inserted into meta_data.")
        cur.close()
    except Exception as e:
        print(f"Error while inserting into meta_data: {e}")
        conn.rollback()

def main():
    conn = connect_to_postgres()
    views = get_all_views(conn)
    print(f"Views to process: {views}")
    
    processed_views = []
    
    for view in views:
        try:
            columns, data = fetch_data_from_view(conn, view)
            if write_data_as_orc(data, columns, view):
                processed_views.append(view)
        except Exception as e:
            print(f"Failed to process view {view}: {e}")
            continue
    
    if processed_views:
        insert_into_meta_data(conn, processed_views)
    
    conn.close()
    print("PostgreSQL connection closed")

if __name__ == "__main__":
    main()