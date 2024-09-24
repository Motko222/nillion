#!/bin/bash

path=$(echo $(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd)
source $path/config
cd $path

echo "------------------------"
cat rpc | nl
echo "------------------------"
read -p "? " n

if [[ $n == ?(-)+([0-9]) ]]
  then
    rpc=$(cat rpc | head -$n | tail -1 )
  else 
    exit 1
fi

./stop.sh

#read -p "Block? " block
#docker run -d -v ~/nillion/accuser:/var/tmp nillion/verifier:$VERSION accuse --rpc-endpoint $rpc --block-start $block
docker run -d -v ~/nillion/accuser:/var/tmp nillion/verifier:$VERSION verify --rpc-endpoint $rpc

container=$(docker ps | grep nillion | awk '{print $NF}')
docker logs -n 200 -f $container
