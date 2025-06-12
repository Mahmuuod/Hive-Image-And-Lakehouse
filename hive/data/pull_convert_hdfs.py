from google.cloud import storage
from google.oauth2 import service_account
import os
import subprocess
import pyarrow.parquet as pq
import pyarrow.orc as orc
import pyarrow as pa

def download_folder_from_gcs(key_path, bucket_name, folder_prefix, local_destination, hdfs_destination):
    """
    Downloads all blobs under a GCS "folder" to a local directory, converts Parquet to ORC,
    and then moves both the original and ORC files to HDFS.
    Ensures the HDFS directory exists before attempting to move files.
    """
    # Initialize Google Cloud Storage client
    credentials = service_account.Credentials.from_service_account_file(key_path)
    client = storage.Client(credentials=credentials)
    bucket = client.bucket(bucket_name)

    blobs = bucket.list_blobs(prefix=folder_prefix)

    for blob in blobs:
        if blob.name.endswith("/"):
            continue  # skip empty folders

        # Determine local path
        relative_path = blob.name[len(folder_prefix):].lstrip("/")
        local_file_path = os.path.join(local_destination, relative_path)

        # Create directories if needed
        os.makedirs(os.path.dirname(local_file_path), exist_ok=True)

        # Download file to local filesystem
        blob.download_to_filename(local_file_path)
        print(f"✅ Downloaded: {blob.name} → {local_file_path}")

        # Convert the Parquet file to ORC
        orc_file_path = local_file_path.replace(".parquet", ".orc")
        convert_parquet_to_orc(local_file_path, orc_file_path)
        print(f"✅ Converted Parquet to ORC: {orc_file_path}")

        # Upload the converted ORC file to HDFS
        upload_to_hdfs(orc_file_path, hdfs_destination)

        # Optionally, delete the local ORC file after uploading to HDFS
        os.remove(orc_file_path)

        # Upload the original Parquet file to HDFS (if needed)
       # upload_to_hdfs(local_file_path, hdfs_destination)

        # Optionally, delete the local Parquet file after moving it to HDFS
        os.remove(local_file_path)

def convert_parquet_to_orc(parquet_file, orc_file):
    """
    Converts a Parquet file to ORC format.
    """
    # Read the Parquet file into a PyArrow Table
    table = pq.read_table(parquet_file)

    # Iterate through the columns and convert time64[us] to int64 (microseconds since epoch)
    for i in range(table.num_columns):
        if pa.types.is_time(table.schema.field(i).type):
            # Convert time64[us] to int64 (microseconds since epoch)
            table = table.set_column(i, table.schema.field(i).name, table.column(i).cast(pa.int64()))

    # Write the table to an ORC file
    with open(orc_file, 'wb') as f:
        orc.write_table(table, f)

def upload_to_hdfs(local_file_path, hdfs_destination, local_base="/tmp"):
    """
    Uploads a file to HDFS.
    """
    # Correct relative path from base
    relative_path = os.path.relpath(local_file_path, start=local_base)
    hdfs_file_path = os.path.join(hdfs_destination, relative_path)

    # Ensure the HDFS directory exists
    hdfs_dir_path = os.path.dirname(hdfs_file_path)
    subprocess.run(["hadoop", "fs", "-mkdir", "-p", hdfs_dir_path], check=True)
    print(f"✅ Created HDFS directory: {hdfs_dir_path}")

    # Move the file to HDFS
    subprocess.run(["hadoop", "fs", "-put", local_file_path, hdfs_file_path], check=True)
    print(f"✅ Moved to HDFS: {local_file_path} → {hdfs_file_path}")

# Example usage
download_folder_from_gcs(
    key_path="/data/key.json",
    bucket_name="airline_dwh",
    folder_prefix="all_tables/",  # must end with a slash
    local_destination="/tmp",  # temporary local directory
    hdfs_destination="/user/hive/warehouse/tables/"
)
