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
sudo docker pull couchbase:5.0.1
docker run -d --name couchbase --net="host" -v /tmp:/tmp couchbase:5.0.1
sleep 5
untilsuccessful docker exec -it couchbase /opt/couchbase/bin/couchbase-cli cluster-init -c localhost:8091 --cluster-username=Administrator --cluster-password=password --cluster-ramsize=512 --service='data;index;query'
untilsuccessful docker exec -it couchbase /opt/couchbase/bin/couchbase-cli bucket-create -c localhost:8091 -u Administrator -p password  --bucket-type=couchbase --bucket=default -c localhost:8091 --bucket-ramsize=100 --wait
untilsuccessful ./bin/gocbupgrade
