
set -e
NODE=$(hostname)

cd
echo $NODE




case "$NODE" in
    meta-store*)

if [ "$NODE" = "meta-store" ]; then
if PGPASSWORD=hive psql -U hive -h postgres -d metastore -tAc 'SELECT 1 FROM public."VERSION" LIMIT 1;' | grep -q 1; then
  echo "[OK] Hive Metastore schema is already initialized."
else
  echo "[WARN] Schema not found — initializing Hive schema..."
  /opt/apache-hive-4.0.1-bin/bin/schematool -dbType postgres -initSchema
fi

else
        while  ! nc -z meta-store 9083 ; do
            echo "Waiting for meta-store"
            sleep 2
        done
        sleep 10

fi


        hive --service metastore    
       ;;
    hive*)
    echo '--------------------------------------------------------'
        while  ! nc -z Master1 9870 ; do
            echo "Waiting for Name Node To Be Formatted ..."
            sleep 2
        done
        sleep 20

        hdfs dfs -test -d /app/ || hdfs dfs -mkdir /app/
        hdfs dfs -test -e /app/tez.tar.gz || hdfs dfs -put /opt/apache-tez-0.10.4-bin/share/tez.tar.gz /app/
        hive --service hiveserver2 &
        while  ! nc -z localhost 10000 ; do
            echo "wait for hive server to be on"
            sleep 2
        done

        ;;
    *)
        echo "Unknown node type: $NODE. No specific configuration applied."
        ;;
esac
echo hive server is on 
tail -f /dev/null & wait
