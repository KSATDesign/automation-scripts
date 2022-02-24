#!/usr/bin/env bash

echo -e
echo  "What is the email address associated with your cloudflare account?"
echo -e
read -r email
sleep 0.2s

echo -e
echo  "What is the Global API Key associated with your cloudflare account?"
echo -e
read -r key

echo -e
echo  "What is the host to be (use @ for root domain)?"
echo -e
read -r domain

echo -e
echo  "What is the FQDN that this MX record will point to?"
echo -e
read -r MXDomain

echo -e
echo  "What priority do you want to set?"
echo -e
read -r priority

curl -X GET "https://api.cloudflare.com/client/v4/zones" \
    -H "X-Auth-Email: $email" \
    -H "X-Auth-Key: $key" \
    -H "Content-Type: application/json" \
    | python -c $'import sys,json\ndata=json.loads(sys.stdin.read())\nif data["success"]:\n\tfor dict in data["result"]:print("Zone ID: " + dict["id"])\nelse:print("ERROR(" + str(data["errors"][0]["code"]) + "): " + data["errors"][0]["message"])' > zoneid.txt


curl -X POST "https://api.cloudflare.com/client/v4/zones/$(sed 's/Zone ID: //' zoneid.txt)/dns_records/" \
-H "X-Auth-Email: $email" \
-H "X-Auth-Key: $key" \
-H "Content-Type: application/json" \
    --data '{"type":"'"MX"'","name":"'"$domain"'","content":"'"$MXDomain"'","priority":'"$priority"',"ttl":'"1"'}' \
| python -m json.tool;

