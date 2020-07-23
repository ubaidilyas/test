#!/bin/sh


consul kv get -token=f2f0b1bf-c45f-75f6-bd8a-f979de740417 -http-addr=https://consul-ui.stg.mondia.io -keys -separator="" letsencrypt > .test.txt

while IFS=/ read -r key value type; do
if [ "$type" = 'cert' ]; then
echo "${value}=`consul kv get -token=f2f0b1bf-c45f-75f6-bd8a-f979de740417 -http-addr=https://consul-ui.stg.mondia.io letsencrypt/${value}/${type} | openssl x509 -enddate -noout`" >>.enddate.txt
fi
done <.test.txt

while IFS== read -r domain notafter date; do

if [ $(((`date -j -f "%b %d %T %Y %Z" "${date}" +%s` - `date +%s`) / 86400)) -lt 30 ]; then
domain=${domain/_/}

#export CF_DNS_API_TOKEN="-NiavYvHFfUfa6thNZwPlI5igPdZs3yZTybSjvfX"
#export CF_ZONE_API_TOKEN="XRG8nAOr7nW38LNQiUFO20HIGqhhfQo_tHIqdpmO"
#lego --server=https://acme-staging-v02.api.letsencrypt.org/directory -d "*${domain}" --email sysops@mondia.com --key-type rsa4096 --accept-tos --dns cloudflare --dns-timeout 90 --dns.resolvers 8.8.8.8 run

value=_${domain}

jq -n --arg kcert letsencrypt/${value}/cert --arg kkey letsencrypt/${value}/key --arg vcert $(base64 -i $(pwd)/.lego/certificates/${value}.crt) --arg vkey $(base64 -i $(pwd)/.lego/certificates/${value}.key) '[{"KV": {"Verb":"set","Key":$kcert,"Value":$vcert}},{"KV": {"Verb":"set","Key": $kkey,"Value": $vkey}}]' >>${domain}.json


	fi
done <.enddate.txt


#add condition of no files
jq -s 'add ' .*.json >.putmonday.json

curl --request PUT --data @.putmonday.json http://127.0.0.1:8500/v1/txn