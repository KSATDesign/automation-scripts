#!/usr/bin/env bash

echo -e
echo  "What is your timezone (Australia/Brisbane)?"
echo -e
read -r timezone
sleep 0.2s

apt-key adv --fetch-keys 'https://mariadb.org/mariadb_release_signing_key.asc'
add-apt-repository 'deb [arch=amd64] http://mariadb.mirror.globo.tech/repo/10.9/debian bullseye main'

wait

apt update

wait

apt upgrade

wait

apt install -y nginx curl software-properties-common mariadb-{server,client} php7.4 php7.4-{cli,zip,gd,fpm,json,common,mysql,zip,mbstring,curl,xml,bcmath,imap,ldap,intl}

wait

sed -i 's/memory_limit =.*/memory_limit = 512M/g' /etc/php/7.4/fpm/php.ini
sed -i 's/date.timezone =.*/date.timezone = '$timezone'/g' /etc/php/7.4/fpm/php.ini

systemctl stop apache2

wait

systemctl disable apache2

wait

mv /etc/nginx/sites-enabled/default{,.bak}


echo "server {
        listen       80 default_server;
        listen       [::]:80 default_server;
        #server_name  subdomain.domain.com;
        root         /var/www/html/firefly-iii/public;
        index index.html index.htm index.php;

        location / {
                try_files $uri /index.php$is_args$args;
                autoindex on;
                sendfile off;
       }

        location ~ \.php$ {
        fastcgi_pass unix:/run/php/php7.4-fpm.sock;
        fastcgi_index index.php;
        fastcgi_read_timeout 240;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
        fastcgi_split_path_info ^(.+.php)(/.+)$;
        }

    }" > /etc/nginx/sites-enabled/firefly.conf

systemctl restart nginx php7.4-fpm

wait

head /dev/urandom | tr -dc A-Za-z0-9 | head -c10 > ~/pass.txt
#mysqladmin password "$(cat ~/pass.txt)"

wait

myql --user=root <<_EOF_
UPDATE mysql.user SET Password=PASSWORD("$(cat ~/pass.txt)") WHERE User='root';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
_EOF_

wait

head /dev/urandom | tr -dc A-Za-z0-9 | head -c10 > ~/fireflyuserpass.txt

myql --user=root  --password=$(cat ~/pass.txt) <<_EOF_
CREATE DATABASE firefly_db;
CREATE USER 'fireflyuser'@'localhost' IDENTIFIED BY '$(cat ~/fireflyuserpass.txt)';
GRANT ALL PRIVILEGES ON firefly_db. * TO 'fireflyuser'@'localhost';
FLUSH PRIVILEGES;
_EOF_

wait

cd ~
curl -sS https://getcomposer.org/installer -o composer-setup.php
sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer

cd /var/www/html/
composer create-project grumpydictator/firefly-iii --no-dev --prefer-dist firefly-iii $(curl -s https://github.com/app/repo/releases|grep -m1 -Eo "archive/refs/tags/[^/]+\.tar\.gz"|egrep -o "([0-9]{1,}\.)+[0-9]{1,}"|xargs printf "%s")

sudo chown -R www-data:www-data firefly-iii

sudo chmod -R 775 firefly-iii/storage
