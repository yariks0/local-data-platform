#!/bin/bash


if [ "$NODE_MODE" == "master" ]; then
    /opt/spark/sbin/start-master.sh -p 7077
    /opt/spark/sbin/start-history-server.sh
elif [ "$NODE_MODE" == "worker" ]; then
    /opt/spark/sbin/start-worker.sh spark://spark-iceberg:7077
else
    echo "Invalid argument. Use 'master' or 'worker'."
    exit 1
fi