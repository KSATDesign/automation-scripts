echo -e
echo  "What is your public IP?"
echo -e
read -r publicip
sleep 0.2s

echo -e
echo  "What is the email associated with your cloudflare account?"
echo -e
read -r email
sleep 0.2s

echo -e
echo  "What is the key associated with your cloudflare account?"
echo -e
read -r key
sleep 0.2s

curl -X POST "https://api.cloudflare.com/client/v4/zones/4655861adabaffe9f0edae4b7884a174/dns_records/" \
    -H "X-Auth-Email: shane@ksatdesign.com.au" \
    -H "X-Auth-Key: e7470d17ce9a6f9c7cf1667f68c4d1807d882" \
    -H "Content-Type: application/json" \
    --data '{"type":"'"A"'","example.com":"'"scripts.ksatdesign.com.au"'","content":"'"203.206.159.191"'","proxied":'"false"',"ttl":'"1"'}' \
    | python -m json.tool;




    curl -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/" \
    -H "X-Auth-Email: $EMAIL" \
    -H "X-Auth-Key: $KEY" \
    -H "Content-Type: application/json" \
    --data '{"type":"'"$TYPE"'","name":"'"$NAME"'","content":"'"$CONTENT"'","proxied":'"$PROXIED"',"ttl":'"$TTL"'}' \
    | python -m json.tool;


    EMAIL="shane@ksatdesign.com.au"; \
KEY="e7470d17ce9a6f9c7cf1667f68c4d1807d882"; \
ZONE_ID="4655861adabaffe9f0edae4b7884a174"; \
TYPE="A"; \
NAME="scripts.ksatdesign.com.au"; \
CONTENT="203.206.159.191"; \
PROXIED="true"; \
TTL="1"; \
curl -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/" \
    -H "X-Auth-Email: $EMAIL" \
    -H "X-Auth-Key: $KEY" \
    -H "Content-Type: application/json" \
    --data '{"type":"'"$TYPE"'","name":"'"$NAME"'","content":"'"$CONTENT"'","proxied":'"$PROXIED"',"ttl":'"$TTL"'}' \
    | python -m json.tool;