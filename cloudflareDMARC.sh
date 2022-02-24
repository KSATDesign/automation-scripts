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

curl -X GET "https://api.cloudflare.com/client/v4/zones" \
    -H "X-Auth-Email: $email" \
    -H "X-Auth-Key: $key" \
    -H "Content-Type: application/json" \
    | python -c $'import sys,json\ndata=json.loads(sys.stdin.read())\nif data["success"]:\n\tfor dict in data["result"]:print("Zone ID: " + dict["id"])\nelse:print("ERROR(" + str(data["errors"][0]["code"]) + "): " + data["errors"][0]["message"])' > zoneid.txt


curl -X POST "https://api.cloudflare.com/client/v4/zones/$(sed 's/Zone ID: //' zoneid.txt)/dns_records/" \
-H "X-Auth-Email: $email" \
-H "X-Auth-Key: $key" \
-H "Content-Type: application/json" \
    --data '{"type":"'"TXT"'","name":"'"_dmarc"'","content":"'"v=DMARC1; p=quarantine; rua=mailto:autoreply@dmarctest.org"'","ttl":'"1"'}' \
| python -m json.tool;