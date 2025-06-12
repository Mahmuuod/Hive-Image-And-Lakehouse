#!/bin/bash

echo "[INFO] Checking Hive Metastore schema status..."

# Run schematool info to check schema existence
$HIVE_HOME/bin/schematool -dbType postgres -info > /dev/null 2>&1

if [[ $? -eq 0 ]]; then
  echo "[OK] Hive Metastore is already initialized."
else
  echo "[WARN] Hive Metastore not initialized. Running initSchema..."
  $HIVE_HOME/bin/schematool -dbType postgres -initSchema

  if [ $? -eq 0 ]; then
    echo "[OK] Hive Metastore schema initialized successfully."
  else
    echo "[ERROR] Failed to initialize Hive Metastore schema."
    exit 1
  fi
fi
