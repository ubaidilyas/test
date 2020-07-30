#!/bin/sh


consul kv get -token=${2} -http-addr=${1} -keys -separator="" letsencrypt > list.txt

while IFS=/ read -r key value type; do
if [ "$type" = 'cert' ]; then
echo "${value}=`consul kv get -token=${2} -http-addr=${1} letsencrypt/${value}/${type} | openssl x509 -enddate -noout`" >>enddate.txt
fi
done <list.txt

while IFS== read -r domain notafter date; do

if [ $(((`date -d "${date}" +%s` - `date +%s`) / 86400)) -lt 30 ]; then
domain=${domain/_/}

export CF_DNS_API_TOKEN="-NiavYvHFfUfa6thNZwPlI5igPdZs3yZTybSjvfX"
export CF_ZONE_API_TOKEN="XRG8nAOr7nW38LNQiUFO20HIGqhhfQo_tHIqdpmO"
lego --server=https://acme-staging-v02.api.letsencrypt.org/directory -d "*${domain}" --email sysops@mondia.com --key-type rsa4096 --accept-tos --dns cloudflare --dns-timeout 90 --dns.resolvers 8.8.8.8 run

value=_${domain}

jq -n --arg kcert letsencrypt/${value}/cert --arg kkey letsencrypt/${value}/key --arg vcert $(base64 -i $(pwd)/.lego/certificates/${value}.crt| tr -d \\n) --arg vkey $(base64 -i $(pwd)/.lego/certificates/${value}.key| tr -d \\n) '[{"KV": {"Verb":"set","Key":$kcert,"Value":$vcert}},{"KV": {"Verb":"set","Key": $kkey,"Value": $vkey}}]' >_${domain}.json


        fi
done <enddate.txt

if [ -n $(ls _*.json|wc -l) ]; then
jq -s 'add ' _*.json >putmonday.json
cat putmonday.json
#curl --request PUT --data @putmonday.json http://127.0.0.1:8500/v1/txn
fi
rm *.txt