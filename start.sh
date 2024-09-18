#!/bin/bash

folder=$(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd)
cd $folder

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

#rpc=https://nillion-testnet-rpc.polkachu.com
#rpc=https://testnet-nillion-rpc.lavenderfive.com
#rpc=https://nillion-testnet.rpc.kjnodes.com
#rpc=http://nillion.testnet.antares.zone:26657

./stop.sh

read -p "Block? " block
docker run -d -v ~/nillion/accuser:/var/tmp nillion/retailtoken-accuser:v2.0.3 accuse --rpc-endpoint $rpc --block-start $block
container=$(docker ps | grep nillion | awk '{print $NF}')
docker logs -n 200 -f $container
