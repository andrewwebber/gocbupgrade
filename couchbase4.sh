#!/bin/bash

untilsuccessful() {
  "$@"
  while [ $? -ne 0 ]
  do
    echo Retrying...
    sleep 1
    "$@"
  done
}

sudo docker stop couchbase
sudo docker rm couchbase
sudo docker pull couchbase/server:enterprise-4.6.1
sudo docker run -d --name couchbase --net="host" -v /tmp:/tmp couchbase/server:enterprise-4.6.1
sleep 5
untilsuccessful /opt/couchbase/bin/couchbase-cli cluster-init -u admin -p password -c 127.0.0.1:8091 --cluster-init-username=Administrator --cluster-init-password=password --cluster-init-ramsize=512 --service='data;index;query'
untilsuccessful /opt/couchbase/bin/couchbase-cli bucket-create -c 127.0.0.1:8091 -u Administrator -p password --bucket=default -c localhost:8091 --bucket-ramsize=100
untilsuccessful ./bin/gocbupgrade
