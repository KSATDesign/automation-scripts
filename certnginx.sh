#!/usr/bin/env bash
sudo apt -y install nginx
sudo snap -y install core; sudo snap refresh core
sudo snap -y install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot

# Install DNS CloudFlare plugin
sudo snap set certbot trust-plugin-with-root=ok
sudo snap -y install certbot-dns-cloudflare

# This directory may not exist yet
sudo mkdir -p /etc/letsencrypt


# using restricted API Token (recommended)##
#sudo tee /etc/letsencrypt/dnscloudflare.ini > /dev/null <<EOT
#dns_cloudflare_api_token = 0123456789abcdef0123456789abcdef01234567

#EOT
##using Global API Key (not recommended)##

#sudo tee /etc/letsencrypt/dnscloudflare.ini > /dev/null <<EOT
# Cloudflare API credentials used by Certbot
#dns_cloudflare_email = cloudflare@example.com
#dns_cloudflare_api_key = 0123456789abcdef0123456789abcdef01234
#
#EOT

# Secure that file (otherwise certbot yells at you)
sudo chmod 0600 /etc/letsencrypt/dnscloudflare.ini

# Create a certificate!
# This has nginx reload upon renewal,
# which assumes Nginx is using the created certificate
# You can also create non-wildcard subdomains, e.g. "-d foo.example.org"
sudo certbot certonly -d *.yourdomain.tld \
    --dns-cloudflare --dns-cloudflare-credentials /etc/letsencrypt/dnscloudflare.ini \
    --post-hook "service nginx reload" \
    --non-interactive --agree-tos \
    --email admin@example.tld

# Test it out
sudo certbot renew --dry-run
