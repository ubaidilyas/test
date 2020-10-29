#!/bin/sh

export CF_DNS_API_TOKEN="${3}"
export CF_ZONE_API_TOKEN="${4}"
consul kv get -token=${2} -http-addr=${1} -keys -separator="" letsencrypt > list.txt
while IFS=/ read -r key value type; do
if [ "$type" = 'cert' ]; then
echo "${value}=`consul kv get -token=${2} -http-addr=${1} letsencrypt/${value}/${type} | openssl x509 -enddate -noout`" >>enddate.txt
fi
done <list.txt
while IFS== read -r domain notafter date; do
if [ $(((`date -d "${date}" +%s` - `date +%s`) / 86400)) -lt 30 ]; then
lego --server=https://acme-staging-v02.api.letsencrypt.org/directory -d "$(echo "${domain}" | sed -e 's/_/*/')" --email sysops@mondia.com --key-type rsa4096 --accept-tos --dns cloudflare --dns-timeout 90 --dns.resolvers 8.8.8.8 run 2>>error.txt
jq -n --arg kcert letsencrypt/${domain}/cert --arg kkey letsencrypt/${domain}/key --arg vcert $(base64 -i $(pwd)/.lego/certificates/${domain}.crt| tr -d \\n) --arg vkey $(base64 -i $(pwd)/.lego/certificates/${domain}.key| tr -d \\n) '[{"KV": {"Verb":"set","Key":$kcert,"Value":$vcert}},{"KV": {"Verb":"set","Key": $kkey,"Value": $vkey}}]' > ${domain}.json
      fi
done <enddate.txt
if ls *.json 2>/dev/null; then
jq -s 'add ' *.json >put.json
#curl -H "X-Consul-Token: ${2}" --request PUT --data @put.json ${1}/v1/txn
fi
