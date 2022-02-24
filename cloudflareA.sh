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
echo  "What is the name of the A record you wish to make?"
echo -e
read -r A

echo -e
echo  "What is IP address for $A?"
echo -e
read -r IP

read -r -p "Would you like to set this as Proxied? [Y/n] " input
 
case $input in
      [yY][eE][sS]|[yY])
curl -X GET "https://api.cloudflare.com/client/v4/zones" \
    -H "X-Auth-Email: $email" \
    -H "X-Auth-Key: $key" \
    -H "Content-Type: application/json" \
    | python -c $'import sys,json\ndata=json.loads(sys.stdin.read())\nif data["success"]:\n\tfor dict in data["result"]:print("Zone ID: " + dict["id"])\nelse:print("ERROR(" + str(data["errors"][0]["code"]) + "): " + data["errors"][0]["message"])' > zoneid.txt

            curl -X POST "https://api.cloudflare.com/client/v4/zones/$(sed 's/Zone ID: //' zoneid.txt)/dns_records/" \
-H "X-Auth-Email: $email" \
-H "X-Auth-Key: $key" \
-H "Content-Type: application/json" \
--data '{"type":"'"A"'","name":"'"$A"'","content":"'"$IP"'","proxied":'"true"',"ttl":'"1"'}' \
| python -m json.tool; 
            ;;
      [nN][oO]|[nN])

curl -X GET "https://api.cloudflare.com/client/v4/zones" \
    -H "X-Auth-Email: $email" \
    -H "X-Auth-Key: $key" \
    -H "Content-Type: application/json" \
    | python -c $'import sys,json\ndata=json.loads(sys.stdin.read())\nif data["success"]:\n\tfor dict in data["result"]:print("Zone ID: " + dict["id"])\nelse:print("ERROR(" + str(data["errors"][0]["code"]) + "): " + data["errors"][0]["message"])' > zoneid.txt
            curl -X POST "https://api.cloudflare.com/client/v4/zones/$(sed 's/Zone ID: //' zoneid.txt)/dns_records/" \
-H "X-Auth-Email: $email" \
-H "X-Auth-Key: $key" \
-H "Content-Type: application/json" \
--data '{"type":"'"A"'","name":"'"$A"'","content":"'"$IP"'","proxied":'"false"',"ttl":'"1"'}' \
| python -m json.tool; 
            ;;
      *)
            echo "Invalid input..."
            exit 1
            ;;
esac
