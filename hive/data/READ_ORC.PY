import pyarrow.orc as orc
import pandas as pd
from hdfs import InsecureClient
import io
import tempfile

def read_orc_from_hdfs(hdfs_path, host='http://master1:9870', user='hadoop'):
    """
    Read ORC file from HDFS including schema and data with proper seek support
    
    Args:
        hdfs_path (str): Full HDFS path to ORC file or directory
        host (str): HDFS Namenode host
        user (str): HDFS user
    
    Returns:
        dict: Contains 'schema' (pyarrow.Schema) and 'data' (pandas.DataFrame)
    """
    try:
        # Connect to HDFS
        client = InsecureClient(host, user=user)
        
        # Check if path exists
        if client.status(hdfs_path, strict=False) is None:
            raise FileNotFoundError(f"Path {hdfs_path} not found in HDFS")
            
        is_dir = client.status(hdfs_path)['type'] == 'DIRECTORY'
        
        # Get all ORC files
        if is_dir:
            files = [f for f in client.list(hdfs_path) 
                    if f.endswith('.orc') or not (f.startswith('_') or f.startswith('.'))]
            orc_files = [f"{hdfs_path}/{f}" for f in files]
        else:
            orc_files = [hdfs_path]
        
        if not orc_files:
            raise ValueError(f"No ORC files found at {hdfs_path}")
        
        # Read first ORC file to get schema (using temp file for seek support)
        with tempfile.NamedTemporaryFile() as tmp:
            client.download(orc_files[0], tmp.name, overwrite=True)
            with open(tmp.name, 'rb') as f:
                orc_reader = orc.ORCFile(f)
                schema = orc_reader.schema
        
        # Read all data
        dfs = []
        for orc_file in orc_files:
            with tempfile.NamedTemporaryFile() as tmp:
                client.download(orc_file, tmp.name, overwrite=True)
                with open(tmp.name, 'rb') as f:
                    dfs.append(orc.ORCFile(f).read().to_pandas())
        
        # Combine DataFrames if multiple files
        combined_df = pd.concat(dfs, ignore_index=True) if len(dfs) > 1 else dfs[0]
        
        return {
            'schema': schema,
            'data': combined_df
        }
        
    except Exception as e:
        print(f"Error reading ORC from HDFS: {str(e)}")
        raise

def print_orc_info(hdfs_path, host='http://master1:9870', user='hadoop'):
    """
    Print schema and sample data from ORC file
    
    Args:
        hdfs_path (str): HDFS path to ORC file/directory
        host (str): HDFS Namenode host
        user (str): HDFS user
    """
    try:
        result = read_orc_from_hdfs(hdfs_path, host, user)
        
        print("\n=== SCHEMA ===")
        print(result['schema'])
        
        print("\n=== DATA (first 5 rows) ===")
        print(result['data'].head())
        
        print(f"\nTotal rows: {len(result['data'])}")
        
    except Exception as e:
        print(f"Error: {str(e)}")

# Example usage:
if __name__ == "__main__":
    # Example path (could be file or directory)
    hdfs_path = "/user/hive/warehouse/views/vw_channel_inc/data.orc"
    
    # Read and display ORC data
    print_orc_info(hdfs_path)