#!/bin/sh

export CF_DNS_API_TOKEN="${3}"
export CF_ZONE_API_TOKEN="${4}"
touch error.txt
consul kv get -token=${2} -http-addr=${1} -keys -separator="" letsencrypt > list.txt
while IFS=/ read -r key value type; do
if [ "$type" = 'cert' ]; then
consul kv get -token=${2} -http-addr=${1} letsencrypt/${value}/${type} > ${value}.crt
echo "${value}=`openssl x509 -in ${value}.crt -enddate -noout`" >>enddate.txt
fi
done <list.txt
while IFS== read -r domain notafter date; do
if [ $(((`date -d "${date}" +%s` - `date +%s`) / 86400)) -lt 30 ]; then
openssl x509 -in ${domain}.crt -ext subjectAltName -noout | sed 's/,/\n/g' |grep -o DNS.* | sed 's/DNS://g' > ${domain}.txt
if [[ $(wc -l <${domain}.txt) -gt 1 ]]; then
lego -d "$(sed -n 1p ${domain}.txt)" -d "$(sed -n 2p ${domain}.txt)" --email sysops@mondia.com --key-type rsa4096 --accept-tos --dns cloudflare --dns-timeout 90 --dns.resolvers 8.8.8.8 run 2>>error.txt
else
lego -d "$(echo "${domain}" | sed -e 's/_/*/')" --email sysops@mondia.com --key-type rsa4096 --accept-tos --dns cloudflare --dns-timeout 90 --dns.resolvers 8.8.8.8 run 2>>error.txt
fi
jq -n --arg kcert letsencrypt/${domain}/cert --arg kkey letsencrypt/${domain}/key --arg vcert $(base64 -i $(pwd)/.lego/certificates/${domain}.crt| tr -d \\n) --arg vkey $(base64 -i $(pwd)/.lego/certificates/${domain}.key| tr -d \\n) '[{"KV": {"Verb":"set","Key":$kcert,"Value":$vcert}},{"KV": {"Verb":"set","Key": $kkey,"Value": $vkey}}]' > ${domain}.json
      fi
done <enddate.txt
if ls *.json 2>/dev/null; then
jq -s 'add ' *.json >put.json
curl -H "X-Consul-Token: ${2}" --request PUT --data @put.json ${1}/v1/txn
fi
