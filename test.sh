#!/bin/sh


date -j -f "%b %d %T %Y %Z" "Sep 14 09:06:16 2020 GMT" "+%s"


lego -d "*.nike.monsooq.es" --email sysops@mondia.com --key-type rsa4096 --accept-tos --dns manual --dns-timeout 90 --dns.resolvers 8.8.8.8 run


#gets all the keys name recursively in lets encrypt (stage)
consul kv get -token=f2f0b1bf-c45f-75f6-bd8a-f979de740417 -http-addr=https://consul-ui.stg.mondia.io -keys -separator="" letsencrypt > test.txt

while IFS=/ read -r key value type; do
if [ "$type" = 'cert' ]; then
consul kv get -token=f2f0b1bf-c45f-75f6-bd8a-f979de740417 -http-addr=https://consul-ui.stg.mondia.io letsencrypt/${value}/${type} | openssl x509 -dates -noout
fi
done <test.txt


consul kv get -token=c62f365c-b2f4-9003-a752-cd8bd49857aa -http-addr=https://consul-ui.liv.mondia.io -keys -separator="" letsencrypt > test.txt


while IFS=/ read -r key value type; do
if [ "$type" = 'cert' ]; then
consul kv get -token=c62f365c-b2f4-9003-a752-cd8bd49857aa -http-addr=https://consul-ui.liv.mondia.io letsencrypt/${value}/${type} | openssl x509 -dates -noout
fi
done <test.txt

base64 -i _.nike.monsooq.es.crt 

###### Put encoded file into the JSON file... #################

cat sample.json | jq '.[].KV.Verb="verb"|.[0].KV.Key="key"|.[0].KV.Value="value"|.[1].KV.Key="key1"|.[1].KV.Value="value1"'

#########################

curl -H "X-Consul-Token: f2f0b1bf-c45f-75f6-bd8a-f979de740417" --request PUT --data @get.json https://consul-ui.stg.mondia.io/v1/txn



