
set -e
NODE=$(hostname)
sudo service ssh start
cd
if  [ ! -d /opt/hadoop/name/current ] ; then

echo hi

case "$NODE" in
    "Master1" ) 
    hdfs --daemon start journalnode  
    sudo echo 1 > /opt/zookeeper/data/myid 
    zkServer.sh start
    echo 'master zookeeper'
        ;;
    "Master2" ) 
    hdfs --daemon start journalnode  
    sudo echo 2 > /opt/zookeeper/data/myid 
    zkServer.sh start
    echo 'master zookeeper'
        ;;
    "Master3")
    hdfs --daemon start journalnode  
    sudo echo 3 > /opt/zookeeper/data/myid 
    zkServer.sh start
    echo 'master zookeeper'
        ;;
    Worker* )
    echo "inside the worker"
        ;;
    *)
        echo "Unknown node type: $NODE. No specific configuration applied."
        ;;
esac


echo 'all nodes are up '

case "$NODE" in
    "Master1" ) 
    while ! nc -z Master1 8485 || ! nc -z Master2 8485 || ! nc -z Master3 8485; do
        echo "Waiting for Journal Nodes on all nodes..."
        sleep 2
    done
    hdfs namenode -format  
    hdfs zkfc -formatZK  
    hdfs --daemon start namenode  
    hdfs --daemon start zkfc 
    yarn --daemon start resourcemanager
    echo 'master start services'
        ;;
    "Master2" | "Master3" ) 
        while  ! nc -z Master1 9870 ; do
            echo "Waiting for Name Node To Be Formatted ..."
            sleep 2
        done
    sleep 20
    hdfs namenode -bootstrapStandby
    hdfs --daemon start namenode
    yarn --daemon start resourcemanager
    hdfs --daemon start zkfc
    echo 'master start services'
        ;;
    Worker* )
    hdfs --daemon start datanode 
    yarn --daemon start nodemanager
    echo 'worker start services'
        ;;
    *)
        echo "Unknown node type: $NODE. No specific configuration applied."
        ;;
esac

echo "$(hostname), Succeed"

else
echo starting the cluster ---------------
    case "$NODE" in
        "Master1")
        echo -----------------------
            hdfs --daemon start journalnode
            hdfs --daemon start namenode  
            zkServer.sh start
            hdfs --daemon start zkfc 
            yarn --daemon start resourcemanager

        ;;
         "Master2" | "Master3")
            hdfs --daemon start journalnode
            hdfs --daemon start namenode  
            zkServer.sh start
            hdfs --daemon start zkfc 
            yarn --daemon start resourcemanager
            
            ;;
        Worker* )
            hdfs --daemon    start datanode 
            yarn --daemon start nodemanager
            ;;
        *)
            echo "Unknown node type: $NODE. No specific configuration applied."
            ;;
    esac
fi
tail -f /dev/null & wait