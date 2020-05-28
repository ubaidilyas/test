#!/bin/sh

#################
"

installed lego
installed jq

Certbot renews certificates every 60 days. For more information about how Certbot works and for community managed 
resources, check out our Get Help page.


Multiple options:
-> at $(cat file) </path/to/script

-> But for a one-off solution, that doesn't require 
root or anything, you can just use date to compute 
the seconds-since-epoch of the target time as well as the 
present time, then use expr to find the difference, and sleep that many seconds.



"
MY SOLUTION:

Check for the least date in the end date. set `at` to that...
create timefile again and set `at` to it

sendmail


-t      Specify the job time using the POSIX time format.  The argument should be in the form [[20]20]07101250[.00] 30101250 where each pair of letters represents the following:

                   CC      The first two digits of the year (the century).
                   YY      The second two digits of the year.
                   MM      The month of the year, from 1 to 12.
                   DD      the day of the month, from 1 to 31.
                   hh      The hour of the day, from 0 to 23.
                   mm      The minute of the hour, from 0 to 59.
                   SS      The second of the minute, from 0 to 61.

             If the CC and YY letter pairs are not specified, the values default to the current year.  If the SS letter pair is not specified, the value defaults to 0.

 


 −f file   Specify  the  pathname of a file to be used as the source of the at-job, instead
                 of standard input.

 −m        Send mail to the  invoking  user  after  the  at-job  has  run,  announcing  its
                 completion.  Standard  output and standard error produced by the at-job shall be
                 mailed to the user as well, unless redirected elsewhere. Mail shall be sent even
                 if the job produces no output.
#################

While gathering info for you, I stumbled upon the solution. Simply getssl -f, to ignore expiry check. 
Thanks. See below, FWIW. current code is version 2.10 Most recent 
version is 2.10 getssl ver. 2.10 Obtain SSL certificates from the letsencrypt.org ACME server 
########
Running Certbot with the certonly command will obtain a certificate and place it in the directory /etc/letsencrypt/live on your system. 
Because Certonly cannot install the certificate from within Docker, you must install the certificate manually according to the 
procedure recommended by the provider of your webserver.

##############


export CF_DNS_API_TOKEN="-NiavYvHFfUfa6thNZwPlI5igPdZs3yZTybSjvfX"
export CF_ZONE_API_TOKEN="XRG8nAOr7nW38LNQiUFO20HIGqhhfQo_tHIqdpmO"
lego --server=https://acme-staging-v02.api.letsencrypt.org/directory -d "*.nike.monsooq.es" --email sysops@mondia.com --key-type rsa4096 --accept-tos --dns cloudflare --dns-timeout 90 --dns.resolvers 8.8.8.8 run



#gets all the keys name recursively in lets encrypt (stage)
consul kv get -token=f2f0b1bf-c45f-75f6-bd8a-f979de740417 -http-addr=https://consul-ui.stg.mondia.io -keys -separator="" letsencrypt > cert.txt

while IFS=/ read -r key value type; do
if [ "$type" = 'cert' ]; then
consul kv get -token=f2f0b1bf-c45f-75f6-bd8a-f979de740417 -http-addr=https://consul-ui.stg.mondia.io letsencrypt/${value}/${type} | openssl x509 -dates -noout
fi
done <cert.txt


consul kv get -token=c62f365c-b2f4-9003-a752-cd8bd49857aa -http-addr=https://consul-ui.liv.mondia.io -keys -separator="" letsencrypt > cert.txt


while IFS=/ read -r key value type; do
if [ "$type" = 'cert' ]; then
consul kv get -token=c62f365c-b2f4-9003-a752-cd8bd49857aa -http-addr=https://consul-ui.liv.mondia.io letsencrypt/${value}/${type} | openssl x509 -dates -noout
fi
done <cert.txt

domain=.nike.monsooq.es

export CF_DNS_API_TOKEN="-NiavYvHFfUfa6thNZwPlI5igPdZs3yZTybSjvfX"
export CF_ZONE_API_TOKEN="XRG8nAOr7nW38LNQiUFO20HIGqhhfQo_tHIqdpmO"
lego --server=https://acme-staging-v02.api.letsencrypt.org/directory -d "*${domain}" --email sysops@mondia.com --key-type rsa4096 --accept-tos --dns cloudflare --dns-timeout 90 --dns.resolvers 8.8.8.8 run




###### Create JSON File #################

domain=.nike.monsooq.es
value=_${domain}



jq -n --arg kcert letsencrypt/${value}/cert --arg kkey letsencrypt/${value}/key --arg vcert $(base64 -i $(pwd)/.lego/certificates/${value}.crt| tr -d \\n) --arg vkey $(base64 -i $(pwd)/.lego/certificates/${value}.key| tr -d \\n) '[{"KV": {"Verb":"set","Key":$kcert,"Value":$vcert}},{"KV": {"Verb":"set","Key": $kkey,"Value": $vkey}}]' >${domain}.json

curl --request PUT --data @testput.json http://127.0.0.1:8500/v1/txn

#######################


git clone -n git:https://github.com/ubaidilyas/test.git --depth 1
cd test
git checkout HEAD finaljan.sh





/mnt/resource/workspace/Testing-admin-jobs/cost-reports