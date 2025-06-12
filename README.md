# 🐘 Hive-on-Tez with PostgreSQL Metastore & BigQuery Migration

## 📘 Overview

This project sets up **Apache Hive** running on the **Tez execution engine** using **PostgreSQL** as the Hive Metastore. It also includes tooling and scripts to **migrate data from Google BigQuery into Hive tables**, enabling an efficient on-prem or cloud-based data warehouse pipeline.

---

## 🧱 Architecture

```
        +------------------+      +-----------------+
        |   BigQuery       | ---> |   Data Export   |
        +------------------+      +-----------------+
                                         |
                                         v
        +--------------------------------------------------+
        |         Hive-on-Tez (Running in Docker)          |
        |                                                  |
        |  +-----------+    +----------------------------+ |
        |  |  Tez DAG  | -> |  HiveServer2 / Metastore   | |
        |  +-----------+    |  (Backed by PostgreSQL DB) | |
        +--------------------------------------------------+
```

---

## 🚀 Features

- Hive 3.x on Tez execution engine
- PostgreSQL 12+ as Hive Metastore
- Dockerized deployment (Docker Compose)
- BigQuery data export & migration via GCS → Hive
- Schema translation & type compatibility handling

---

## 📦 Prerequisites

- Docker & Docker Compose
- Google Cloud SDK (for BigQuery export)
- GCP project and access to BigQuery dataset
- Python 3.8+ (optional: for schema converter)




# Hive on Tez with Postgres Metastore & BigQuery Migration

This project builds a Docker image for Apache Hive running on Tez, using PostgreSQL as the Hive Metastore, and includes migration support from Google BigQuery to Hive.

## 📦 Project Structure

- `Dockerfile` – Builds the Hive environment with necessary dependencies.
- `postgres-init.sql` – Initializes the PostgreSQL database schema for Hive Metastore.
- `entrypoint.sh` – Custom script to initialize services on container startup.

## 🐳 Docker Image Overview

This Docker image includes:

- Apache Hive
- Apache Tez
- Hadoop (dependencies for Hive and Tez)
- PostgreSQL client
- Google Cloud SDK (for BigQuery data export)

### 🛠 Build the Image

```bash
docker build -t hive-tez-postgres .
```

### ▶️ Run the Container

```bash
docker run -d --name hive-tez \
  -p 10000:10000 \
  -e POSTGRES_HOST=your_postgres_host \
  -e POSTGRES_DB=hive_metastore \
  -e POSTGRES_USER=hive \
  -e POSTGRES_PASSWORD=your_password \
  hive-tez-postgres
```

# Hive Configuration Documentation (`hive-site.xml`)

This file configures the behavior of Apache Hive for execution, metadata management, query planning, and integration with the Tez execution engine. Below is a breakdown of key properties defined.

---

## 🧠 Metastore Configuration

```xml
<property>
  <name>hive.metastore.local</name>
  <value>false</value>
</property>
```
- Connects to a remote Hive Metastore (not embedded).

```xml
<property>
  <name>javax.jdo.option.ConnectionURL</name>
  <value>jdbc:postgresql://postgres:5432/metastore</value>
</property>
```
- Connects the Hive Metastore to a PostgreSQL database.

```xml
<property>
  <name>javax.jdo.option.ConnectionDriverName</name>
  <value>org.postgresql.Driver</value>
</property>
```
- Uses the PostgreSQL JDBC driver.

---

## 🔐 Authentication & Authorization

```xml
<property>
  <name>hive.security.authorization.enabled</name>
  <value>false</value>
</property>
```
- Disables Hive's authorization layer for simplicity.

---

## 🗄️ Schema Auto-Creation (Dev Mode)

```xml
<property>
  <name>datanucleus.autoCreateSchema</name>
  <value>true</value>
</property>
```
- Allows Hive to automatically create schema objects in the metastore DB.

---

## 🔗 Metastore URIs

```xml
<property>
  <name>hive.metastore.uris</name>
  <value>thrift://meta-store:9083,thrift://meta-store2:9084</value>
</property>
```
- Lists available Hive Metastore services for high availability.

---

## 🧪 HiveServer2 Configuration

```xml
<property>
  <name>hive.server2.thrift.port</name>
  <value>10000</value>
</property>
```
- Configures the listening port for HiveServer2.

```xml
<property>
  <name>hive.server2.thrift.bind.host</name>
  <value>0.0.0.0</value>
</property>
```
- Binds the HiveServer2 service to all interfaces.

---

## 🚀 Tez Execution Engine

```xml
<property>
  <name>hive.execution.engine</name>
  <value>tez</value>
</property>
```
- Enables Tez as the execution engine instead of MapReduce.

```xml
<property>
  <name>tez.lib.uris</name>
  <value>hdfs:///app/tez.tar.gz</value>
</property>
```
- Points to the Tez libraries archive in HDFS.

```xml
<property>
  <name>hive.tez.container.size</name>
  <value>2048</value>
</property>
```
- Sets the memory allocation per Tez container.

---

## 🔁 Session Management

```xml
<property>
  <name>hive.server2.tez.initialize.default.sessions</name>
  <value>true</value>
</property>
```
- Enables pre-warming of Tez sessions for better performance.

```xml
<property>
  <name>hive.server2.tez.session.lifetime</name>
  <value>3600000</value>
</property>
```
- Sets Tez session lifetime (1 hour).

---

## 💾 ACID & Partitioning

```xml
<property>
  <name>hive.support.concurrency</name>
  <value>true</value>
</property>
```
- Enables transactional (ACID) support.

```xml
<property>
  <name>hive.txn.manager</name>
  <value>org.apache.hadoop.hive.ql.lockmgr.DbTxnManager</value>
</property>
```
- Uses the database transaction manager.

```xml
<property>
  <name>hive.exec.dynamic.partition</name>
  <value>true</value>
</property>
```

```xml
<property>
  <name>hive.exec.dynamic.partition.mode</name>
  <value>nonstrict</value>
</property>
```
- Allows dynamic partitioning without explicitly defining all partitions.

---

## 📚 Summary

This `hive-site.xml` file prepares Hive for production use with:
- A remote PostgreSQL metastore.
- External Tez engine for performance.
- Session pooling.
- Partitioning, bucketing, and transactional features for scalability.



## 🗃 PostgreSQL Metastore

Ensure you have a PostgreSQL instance with the Hive Metastore schema. You can use the provided `postgres-init.sql` or manually create the database using the Hive schema scripts.

## 🔄 BigQuery to Hive Migration

Use the Google Cloud SDK to export BigQuery data as CSV or Avro to Google Cloud Storage, and then move it to HDFS using `gsutil` or local staging.

### Example Steps:

1. Export BigQuery data to GCS:
   ```bash
   bq extract --destination_format=CSV 'project.dataset.table' gs://your-bucket/data.csv
   ```

2. Copy from GCS to local or HDFS:
   ```bash
   gsutil cp gs://your-bucket/data.csv .
   hdfs dfs -put data.csv /user/hive/warehouse/your_table/
   ```

3. Create and load Hive table:
   ```sql
   CREATE EXTERNAL TABLE your_table (
     col1 STRING,
     col2 INT
   )
   ROW FORMAT DELIMITED
   FIELDS TERMINATED BY ','
   STORED AS TEXTFILE
   LOCATION '/user/hive/warehouse/your_table/';
   ```

# Dockerfile Documentation: Hive on Tez with Postgres Metastore

This Dockerfile sets up an environment to run Apache Hive with Tez as the execution engine and PostgreSQL as the metastore backend. Below is an explanation of each section of the Dockerfile.

---

## 🏗 Base Image

```dockerfile
FROM openjdk:8-jdk
```

- Uses the official OpenJDK 8 image as the base.
- Required for running Hadoop, Hive, and Tez.

---

## 📂 Environment Variables

```dockerfile
ENV HIVE_VERSION=3.1.2
ENV HADOOP_VERSION=3.2.1
```

- Sets specific versions for Hive and Hadoop to ensure compatibility.

---

## 📦 Install Dependencies

```dockerfile
RUN apt-get update && apt-get install -y ...
```

- Updates package lists.
- Installs utilities like `wget`, `curl`, `procps`, `ssh`, `vim`, `net-tools`, `python`, etc.
- Ensures the container has basic tools for debugging and operations.

---

## ⬇️ Download & Install Hadoop

```dockerfile
RUN wget ... && tar -xzf ... && mv ...
```

- Downloads Hadoop from the Apache archive.
- Extracts and installs it to `/opt/`.

---

## ⬇️ Download & Install Hive

```dockerfile
RUN wget ... && tar -xzf ... && mv ...
```

- Downloads Apache Hive.
- Moves it to `/opt/`.

---

## ⬇️ Download & Install Tez

```dockerfile
RUN wget ... && tar -xzf ... && mv ...
```

- Downloads Apache Tez.
- Required as the execution engine for Hive.

---

## 🔧 Configurations

```dockerfile
COPY hive-site.xml ...
COPY tez-site.xml ...
COPY core-site.xml ...
COPY hdfs-site.xml ...
```

- Copies custom configuration files into the appropriate Hive and Hadoop directories.
- These XML files configure Hive Metastore, HDFS, and Tez.

---

## 🧪 PostgreSQL JDBC Driver

```dockerfile
COPY postgresql-<version>.jar ...
```

- Adds the PostgreSQL JDBC driver to Hive's lib folder for Metastore connectivity.

---

## 🚀 Entry Point

```dockerfile
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
```

- Copies and sets execute permission on an entrypoint script.
- `entrypoint.sh` initializes Hive services when the container starts.

---

## 📁 Work Directory

```dockerfile
WORKDIR /opt/hive
```

- Sets the default working directory to Hive's root folder.

---

## 📡 Port Exposure

```dockerfile
EXPOSE 10000
```

- Exposes port `10000`, which is the default port for HiveServer2.

---

## 📝 Summary

This Dockerfile creates a ready-to-run environment for Hive on Tez with Postgres metastore, suitable for development or testing of Hadoop ecosystem applications.

# Hive Startup Script Documentation

This script initializes and launches Hive components depending on the hostname of the container. It uses the hostname to determine the role (`meta-store`, `hive`, etc.) and executes the appropriate logic.

---

## 🔧 Script Logic Breakdown

### General Initialization

```bash
set -e
NODE=$(hostname)

cd
echo $NODE
```

- `set -e`: Makes the script exit on any error.
- `NODE=$(hostname)`: Gets the current container's hostname to identify which Hive component to start.
- `cd` and `echo $NODE`: Changes to the home directory and prints the hostname.

---

## 🧠 Role-Based Logic

The script uses a `case` statement to apply different behavior based on the node's role.

### 🗃 Meta-Store Node

```bash
case "$NODE" in
    meta-store*)
```

#### Schema Initialization

```bash
if [ "$NODE" = "meta-store" ]; then
  if PGPASSWORD=hive psql -U hive -h postgres -d metastore -tAc 'SELECT 1 FROM public."VERSION" LIMIT 1;' | grep -q 1; then
    echo "[OK] Hive Metastore schema is already initialized."
  else
    echo "[WARN] Schema not found — initializing Hive schema..."
    /opt/apache-hive-4.0.1-bin/bin/schematool -dbType postgres -initSchema
  fi
```

- Checks if the Hive Metastore schema is initialized in PostgreSQL.
- If not found, it initializes it using `schematool`.

#### Service Startup (on non-meta-store nodes)

```bash
else
  while ! nc -z meta-store 9083 ; do
    echo "Waiting for meta-store"
    sleep 2
  done
  sleep 10
fi
hive --service metastore
```

- Waits for the Metastore to be reachable (port 9083).
- Starts the Hive Metastore service.

---

### 🐝 Hive Server Node

```bash
hive*)
```

#### Wait for HDFS

```bash
while ! nc -z Master1 9870 ; do
  echo "Waiting for Name Node To Be Formatted ..."
  sleep 2
done
sleep 20
```

- Waits until HDFS NameNode on `Master1` is up (port 9870).

#### HDFS Initialization

```bash
hdfs dfs -test -d /app/ || hdfs dfs -mkdir /app/
hdfs dfs -test -e /app/tez.tar.gz || hdfs dfs -put /opt/apache-tez-0.10.4-bin/share/tez.tar.gz /app/
```

- Creates `/app/` directory in HDFS if not exists.
- Uploads Tez archive to HDFS if not already present.

#### Start HiveServer2

```bash
hive --service hiveserver2 &
while ! nc -z localhost 10000 ; do
  echo "wait for hive server to be on"
  sleep 2
done
```

- Starts HiveServer2 in the background.
- Waits until it becomes available on port `10000`.

---

### 🔁 Default Case

```bash
*)
  echo "Unknown node type: $NODE. No specific configuration applied."
  ;;
```

- For any unknown node hostname, prints a message and applies no special configuration.

---

### ✅ Final Log Message and Background Wait

```bash
echo hive server is on 
tail -f /dev/null & wait
```

- Keeps the container alive by tailing `/dev/null`.

---

## 📝 Summary

This script provides a dynamic way to start either the Hive Metastore or HiveServer2 depending on the container role, while also handling initialization and service readiness.

# Hive Data Warehouse DDL Documentation

This document explains the contents of the `ddl.sql` script which is used to define and populate a Hive-based Data Warehouse schema for an airline reservation system.

---

## 🏗️ Database Initialization

```sql
CREATE DATABASE IF NOT EXISTS DWH_Project
...
```

- Creates a Hive database with metadata properties such as creator and purpose.
- Ensures it doesn't overwrite an existing database.

---

## ⚙️ Hive Configuration Settings

```sql
SET hive.exec.dynamic.partition = true;
...
```

- Enables dynamic partitioning and enforces bucketing and sorting for better performance on large datasets.

---

## 📊 Dimension and Fact Tables

The script includes definitions and loading logic for:

### `dim_airport`, `dim_passenger`, `dim_promotions`, etc.
- Represent lookup and descriptive information.
- Use `EXTERNAL TABLE` for flexibility in data location.

### `fact_reservation` (staging and final)
- Collects transactional booking data.
- Final table is `PARTITIONED BY (year)` and `CLUSTERED BY Reservation_Key INTO 16 BUCKETS`.

---

## 🔄 ETL Logic

```sql
INSERT OVERWRITE TABLE fact_reservation PARTITION (year)
...
```

- Loads data from `stage_fact_reservation` into the optimized final table.
- Computes the `year` partition from the `reservation_date_key`.

---

## 🧹 Cleanup

```sql
DROP TABLE stage_fact_reservation;
```

- Removes staging table after loading to keep schema clean.

---
# Hive Transformation Script Documentation

This documentation explains the transformation process executed in `transformation.sql` for preparing data for the Hive Data Warehouse.

---

## 🔁 Transformation Flow

1. **Create `temp_fact_reservation` table**  
   - Aggregates and formats data from multiple normalized operational tables.
   - Handles nulls using `COALESCE`.
   - Extracts date keys as `BIGINT` for efficient partitioning.

2. **Join Logic**
   - Performs `JOIN` operations between:
     - `reservation`
     - `ticket`
     - `seat`
     - `flight`
     - `passenger`
     - `aircraft`
     - `channel`
     - `fare_basis`
     - `promotion` (as `LEFT JOIN` for optional discounts)

---

## 📤 Data Load

```sql
INSERT INTO TABLE dwh_project.fact_reservation PARTITION(year)
...
```

- Loads from `temp_fact_reservation` to the fact table.
- Extracts `year` from `reservation_date_key`.

---

## 🧹 Cleanup

```sql
DROP TABLE temp_fact_reservation;
```

- Removes temporary transformation table post-load.
# PostgreSQL Operational DDL Script Documentation

This file explains the `db_ddl.sql` script which sets up the normalized schema for the airline operational database in PostgreSQL.

---

## 🏗️ Schema Overview

Includes 18 tables for OLTP design:

- Entities: `airport`, `aircraft_model`, `passenger`, `promotion`, `reservation`, etc.
- Uses strong constraints, identity primary keys, and foreign keys.
- Many-to-many relationships managed via join tables (e.g. `flight_crew`).

---

## 🛡️ Constraints & Validations

- Unique constraints (e.g. `airport_code_unique`)
- Enum-like checks (e.g. `status IN (...)`)
- Composite keys where required (e.g. seat uniqueness)

---

## 🔁 Audit Columns

Each table includes:

```sql
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
```

- Tracked by triggers (`trg_*_update_timestamp`) that auto-update `updated_at`.

---

## 🧠 Metadata & Functions

- `meta_data` table tracks the last extraction time.
- `get_last_extraction_time()` retrieves last pull for CDC.
- Incremental views (`vw_*_inc`) reflect only recently modified rows.
# Hive External Views Schema Documentation

This document describes the `db_HQL.sql` file which builds Hive external tables mapped to ORC files generated from PostgreSQL CDC views.

---

## 🗃️ Hive Setup

```sql
DROP DATABASE IF EXISTS airline_views CASCADE;
CREATE DATABASE airline_views;
USE airline_views;
```

- Resets the view layer for Hive-based analytics.

---

## 🧩 Table Mappings

Each table (e.g. `airport`, `passenger`, `reservation`) is:

- Defined as an `EXTERNAL TABLE`
- Points to an ORC file location produced by incremental views
- Allows Hive to query CDC data directly without ingestion

---

## 🔄 Sync Strategy

- Tables reflect the state of `vw_*_inc` views in PostgreSQL.
- External ORC files are assumed to be updated regularly via ETL or Airflow jobs.

---

## 📈 Use Case

Ideal for:

- Hybrid analytics platforms
- Hive, Presto, or SparkSQL-based reporting over near real-time views



## 🧷 Notes

- Netcat (`nc`) is used to ensure critical ports are up before continuing
- The final line `tail -f /dev/null & wait` keeps the container running after services start

---
Maintained by **Data Engineering Enthusiasts**.
Software Developer | Linux Enthusiast  
Feel free to contribute or suggest improvements via GitHub.

## 🧑‍💻 Author

- [Your Name](https://github.com/your-github)
- Contributions welcome! Please open a PR or issue.
