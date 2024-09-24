#!/bin/bash

source ~/.bash_profile

id=$NILLION_ID
chain=nillion-chain-testnet-1
network=testnet
type=node
grp=node
owner=$OWNER
tail=100000

cd ~/nillion/accuser

container=$(docker ps | grep nillion | awk '{print $NF}')
[ $container ] && docker_status=$(docker inspect $container | jq -r .[].State.Status)
last_challenge=$(docker logs --tail $tail $container | grep -a "Challenges sent to chain" | awk '{print $1}' | tail -1 | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2};?)?)?[mGK]//g")
[ -z $last_challenge ] && last_challenge_sec=never || last_challenge_sec="$(( $(date +%s) - $(date -d $last_challenge +%s) ))s"
local_height=$(docker logs --tail $tail $container | grep -a "Sent block @ height" | tail -1 | awk '{print $NF}')
is_accusing=$(docker logs --tail $tail $container | grep accusing | tail -1 | grep -c "Accuser IS accusing")
verifying=$(docker logs --tail $tail $container | grep "Verifying" | tail -1 | grep -c "Verifying: true")
sent=$(docker logs --tail $tail $container | grep -a "Challenges sent to Nilchain" | tail -1 | awk '{print $NF}')
url=$(ps aux | grep nillion | grep -v grep | awk -F '--rpc-endpoint ' '{print $2}' | awk '{print $1}')
version=$(docker ps -a --no-trunc | grep nillion | awk -F 'verifier:' '{print $2}' | awk '{print $1}')

case $docker_status$verifying in
  running1) status=ok; message="sent=$sent" ;;
  running0) status=warning; message="not verifying, sent=$sent" ;;
  *) status="error"; message="docker not running" ;;
esac

cat << EOF
{
  "updated":"$(date --utc +%FT%TZ)",
  "measurement":"report",
  "tags": [   
   { "key":"id","value":"$id" },
   { "key":"machine","value":"$MACHINE" },
   { "key":"grp","value":"$grp" },
   { "key":"owner","value":"$owner" }
  ],
  "fields": [
   { "key":"status","value":"$status" },
   { "key":"message","value":"$message" },
   { "key":"docker_status","value":"$docker_status" },
   { "key":"local_height","value":"$local_height" },
   { "key":"last_challenge_sec","value":"$last_challenge_sec" },
   { "key":"sent","value":"$sent" },
   { "key":"is_accusing","value":"$is_accusing" },
   { "key":"verifying","value":"$verifying" },
   { "key":"url","value":"$url" },
   { "key":"version","value":"$version" }
  ]
}
EOF

# send data to influxdb
if [ ! -z $INFLUX_HOST ]
then
 curl --request POST \
 "$INFLUX_HOST/api/v2/write?org=$INFLUX_ORG&bucket=$INFLUX_BUCKET&precision=ns" \
  --header "Authorization: Token $INFLUX_TOKEN" \
  --header "Content-Type: text/plain; charset=utf-8" \
  --header "Accept: application/json" \
  --data-binary "
    report,id=$id,machine=$MACHINE,grp=$grp,owner=$owner status=\"$status\",message=\"$message\",version=\"$version\",url=\"$url\",chain=\"$chain\",local_height=\"$local_height\",network=\"$network\" $(date +%s%N) 
    "
fi
