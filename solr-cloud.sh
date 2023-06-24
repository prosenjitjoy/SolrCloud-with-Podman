#!/bin/bash

set -o errexit
set -o errtrace
set -o nounset
set -o pipefail


if [ -z "$(command -v podman)" ]; then
  echo "ERR: podman is not installed"
  echo "RUN: sudo apt install podman"
  exit 1
fi

podman network create solrcloud

podman run --name zoo1 --hostname zoo1 --network solrcloud -p 2181:2181 -e ZOO_MY_ID="1" -e ZOO_SERVERS="server.1=zoo1:2888:3888;2181 server.2=zoo2:2888:3888;2181 server.3=zoo3:2888:3888;2181" -e ZOO_4LW_COMMANDS_WHITELIST=mntr,conf,ruok -d zookeeper:latest

podman run --name zoo2 --hostname zoo2 --network solrcloud -p 2182:2181 -e ZOO_MY_ID="2" -e ZOO_SERVERS="server.1=zoo1:2888:3888;2181 server.2=zoo2:2888:3888;2181 server.3=zoo3:2888:3888;2181" -e ZOO_4LW_COMMANDS_WHITELIST=mntr,conf,ruok -d zookeeper:latest

podman run --name zoo3 --hostname zoo3 --network solrcloud -p 2183:2181 -e ZOO_MY_ID="3" -e ZOO_SERVERS="server.1=zoo1:2888:3888;2181 server.2=zoo2:2888:3888;2181 server.3=zoo3:2888:3888;2181" -d zookeeper:latest

podman run --name solr1 --hostname solr1 --network solrcloud -p 8981:8983 -e ZK_HOST=zoo1:2181,zoo2:2181,zoo3:2181 -d solr:latest

podman run --name solr2 --hostname solr2 --network solrcloud -p 8982:8983 -e ZK_HOST=zoo1:2181,zoo2:2181,zoo3:2181 -d solr:latest

podman run --name solr3 --hostname solr3 --network solrcloud -p 8983:8983 -e ZK_HOST=zoo1:2181,zoo2:2181,zoo3:2181 -d solr:latest