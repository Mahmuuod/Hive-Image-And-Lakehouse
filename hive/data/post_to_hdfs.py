import psycopg2
from hdfs import InsecureClient
import csv
import io

def connect_to_postgres():
    try:
        # Connect to PostgreSQL
        conn = psycopg2.connect(
            host="db",  # PostgreSQL container name (or IP address for external)
            port="5432",  # Default PostgreSQL port
            dbname="postgres",  # Database name
            user="postgres",  # PostgreSQL user
            password="123"  # PostgreSQL password
        )
        print("Connection to PostgreSQL successful")
        return conn
    except Exception as e:
        print(f"Error: Unable to connect to the database. {e}")
        raise

def fetch_data_from_postgres(conn):
    try:
        # Create a cursor object
        cur = conn.cursor()

        # Execute the query to fetch data from inc_load table
        cur.execute("SELECT * from inc_load;")

        # Fetch all the data
        data = cur.fetchall()

        # Get column names from the cursor description
        columns = [desc[0] for desc in cur.description]

        # Close the cursor
        cur.close()

        return columns, data
    except Exception as e:
        print(f"Error while fetching data: {e}")
        raise

def write_data_to_hdfs(data, columns):
    try:
        # Initialize HDFS client (make sure the HDFS URI is correct)
        hdfs_client = InsecureClient('http://master1:9870', user='hadoop')

        # HDFS path where data will be written
        hdfs_path = '/user/hadoop/inc_load_data.csv'

        # Write data to HDFS
        with hdfs_client.write(hdfs_path, overwrite=True) as writer:
            # Create a CSV writer
            csv_writer = csv.writer(writer)

            # Write the header (columns)
            csv_writer.writerow(columns)

            # Write data rows
            csv_writer.writerows(data)

        print(f"Data successfully loaded to HDFS at {hdfs_path}")
        return True
    except Exception as e:
        print(f"Error while writing to HDFS: {e}")
        return False

def insert_into_meta_data(conn):
    try:
        # Create a cursor object
        cur = conn.cursor()

        # Insert the new row into meta_data table
        cur.execute("""
            INSERT INTO public.meta_data (id)
            VALUES ((SELECT COALESCE(MAX(id), 0) + 1 FROM public.meta_data));
        """)

        # Commit the transaction
        conn.commit()
        print("Successfully inserted into meta_data.")
        cur.close()
    except Exception as e:
        print(f"Error while inserting into meta_data: {e}")
        conn.rollback()

def main():
    # Step 1: Connect to PostgreSQL
    conn = connect_to_postgres()

    # Step 2: Fetch data from PostgreSQL
    columns, data = fetch_data_from_postgres(conn)

    # Step 3: Write data to HDFS
    if write_data_to_hdfs(data, columns):
        # Step 4: Insert into meta_data after successful data load
        insert_into_meta_data(conn)

    # Step 5: Close the PostgreSQL connection
    conn.close()
    print("PostgreSQL connection closed")

if __name__ == "__main__":
    main()
