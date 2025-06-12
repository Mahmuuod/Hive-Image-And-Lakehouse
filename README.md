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

---

## 📁 Project Structure

```
.
├── docker-compose.yml          # Hive, Tez, PostgreSQL containers
├── hive-site.xml               # Hive configuration
├── init-metastore.sql          # Schema setup for PostgreSQL metastore
├── bigquery_export/
│   ├── export_script.sh        # Exports BigQuery tables to GCS
│   ├── download_from_gcs.py    # Downloads GCS files locally
│   └── bq_to_hive_schema.py    # Converts BigQuery schema to Hive
├── hive/
│   ├── create_tables.hql       # HQL scripts to create Hive tables
│   └── load_data.hql           # Load statements
└── README.md                   # You are here
```

---

## ⚙️ Setup & Installation

### 1. Clone the Repo

```bash
git clone https://github.com/your-org/hive-tez-bq-migration.git
cd hive-tez-bq-migration
```

### 2. Start Hive-on-Tez with PostgreSQL

```bash
docker-compose up -d
```

This launches:

- HiveServer2
- Tez application master
- PostgreSQL Metastore

Wait until containers are healthy.

---

## ☁️ BigQuery Export & Migration

### Step 1: Export BigQuery Table to GCS

```bash
cd bigquery_export
bash export_script.sh your_dataset your_table gs://your-bucket/export/
```

### Step 2: Download from GCS

```bash
python3 download_from_gcs.py --bucket your-bucket --prefix export/
```

### Step 3: Convert BigQuery Schema to Hive

```bash
python3 bq_to_hive_schema.py --bq_table_schema schema.json > hive/create_tables.hql
```

---

## 🐝 Load Data into Hive

### 1. Create Hive Tables

```bash
docker exec -it hive-server bash
beeline -u jdbc:hive2://localhost:10000 -n hive -p hive -f /scripts/create_tables.hql
```

### 2. Load Data

Update `load_data.hql` to point to the downloaded file paths, then:

```bash
beeline -u jdbc:hive2://localhost:10000 -n hive -p hive -f /scripts/load_data.hql
```

---

## 🧪 Testing

Verify data is available in Hive:

```sql
SELECT COUNT(*) FROM your_table;
```

---

## 🛠️ Troubleshooting

- Ensure HiveServer2 has access to the location of data files
- Check logs using: `docker logs hive-server`
- If Tez is not executing, validate Tez libraries are in the classpath

---

## 📚 References

- [Apache Hive Documentation](https://cwiki.apache.org/confluence/display/Hive/Home)
- [Tez Execution Engine](https://tez.apache.org/)
- [Google BigQuery Exporting Data](https://cloud.google.com/bigquery/docs/exporting-data)
- [Hive Metastore with PostgreSQL](https://cwiki.apache.org/confluence/display/Hive/AdminManual+Metastore+Administration)

---

## 🧑‍💻 Author

- [Your Name](https://github.com/your-github)
- Contributions welcome! Please open a PR or issue.
