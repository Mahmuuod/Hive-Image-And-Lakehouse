from google.cloud import storage
from google.oauth2 import service_account
import os
import subprocess

def download_folder_from_gcs(key_path, bucket_name, folder_prefix, local_destination, hdfs_destination):
    """
    Downloads all blobs under a GCS "folder" to a local directory and then moves them to HDFS.
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

        # Prepare HDFS path
        hdfs_file_path = os.path.join(hdfs_destination, relative_path)

        # Ensure the HDFS directory exists
        hdfs_dir_path = os.path.dirname(hdfs_file_path)
        subprocess.run(["hadoop", "fs", "-mkdir", "-p", hdfs_dir_path], check=True)
        print(f"✅ Created HDFS directory: {hdfs_dir_path}")

        # Move the file to HDFS
        subprocess.run(["hadoop", "fs", "-put", local_file_path, hdfs_file_path], check=True)
        print(f"✅ Moved to HDFS: {local_file_path} → {hdfs_file_path}")

        # Optionally, delete the local file after moving it to HDFS
        os.remove(local_file_path)

# Example usage
download_folder_from_gcs(
    key_path="/data/key.json",
    bucket_name="airline_dwh",
    folder_prefix="all_tables/",  # must end with a slash
    local_destination="/tmp",  # temporary local directory
    hdfs_destination="/user/hive/warehouse/tables/"
)