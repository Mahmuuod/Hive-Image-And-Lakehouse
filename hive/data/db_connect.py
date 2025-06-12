import psycopg2
from psycopg2 import sql

# Connect to your PostgreSQL container
conn = psycopg2.connect(
    host="db",  # 'db' is the container name
    port="5432",  # Default PostgreSQL port inside the container
    dbname="postgres",  # Database name (default PostgreSQL database)
    user="postgres",  # PostgreSQL user
    password="123"  # Password for the user
)

# Create a cursor object
cur = conn.cursor()

# Execute a query (Example)
cur.execute("SELECT * from inc_load;")

# Fetch the result
db_version = cur.fetchone()

# Print the PostgreSQL version
print(f"PostgreSQL version: {db_version}")

# Close the cursor and connection
cur.close()
conn.close()
