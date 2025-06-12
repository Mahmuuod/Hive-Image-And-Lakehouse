import os
from pyspark.sql import SparkSession

# Set your input and output directories
input_base_path = "./local-folder"
output_base_path = "./orc"

# Start Spark
spark = SparkSession.builder \
    .appName("BulkParquetToORC") \
    .getOrCreate()

# Walk through the directory tree
for root, dirs, files in os.walk(input_base_path):
    for file in files:
        if file.endswith(".parquet"):
            parquet_path = os.path.join(root, file)

            # Relative path for output
            relative_path = os.path.relpath(root, input_base_path)
            orc_output_path = os.path.join(output_base_path, relative_path)

            print(f"🔄 Converting {parquet_path} → {orc_output_path}")

            # Read and write
            df = spark.read.parquet(parquet_path)
            df.write.mode("overwrite").orc(orc_output_path)

print("✅ All Parquet files converted to ORC.")

spark.stop()