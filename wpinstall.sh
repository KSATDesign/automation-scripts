{\rtf1\ansi\ansicpg1252\cocoartf1561\cocoasubrtf600
{\fonttbl\f0\fnil\fcharset0 HelveticaNeue;}
{\colortbl;\red255\green255\blue255;\red53\green53\blue53;\red220\green161\blue13;}
{\*\expandedcolortbl;;\cssrgb\c27059\c27059\c27059;\cssrgb\c89412\c68627\c3922;}
\paperw11900\paperh16840\margl1440\margr1440\vieww10800\viewh8400\viewkind0
\deftab560
\pard\pardeftab560\slleading20\partightenfactor0

\f0\fs24 \cf2 #!/usr/bin/env bash\
echo  "What is the web root Path of the virtual host? (ie /var/lib/nethserver/vhost/xxxxxxxxxxxxxxx/)"\
\
read -r location\
echo -e\
sleep 0.5s\
echo  "What is the FQDN of the virtual host? (ie virtualhost.yourserver)"\
\
read -r url\
echo -e\
sleep 0.5s\
\
echo "Thank you processing your request this may take a moment"\
sleep 0.5s\
cd $location\
wget https://wordpress.org/latest.tar.gz && tar -zxvf latest.tar.gz --strip 1 && find ./* -type d -exec chmod 775 \{\} + && find ./* -type f -exec chmod 644 \{\} + && chown apache:apache -R ./* && systemctl restart httpd\
# create random password\
PASSWDDB="$(openssl rand -base64 12)"\
\
# replace "-" with "_" for database username\
MAINDB=$\{USER_NAME//[^a-zA-Z0-9]/wordpress\}\
\
# If /root/.my.cnf exists then it won't ask for root password\
if [ -f /root/.my.cnf ]; then\
\
    mysql -e "CREATE DATABASE $\{MAINDB\} /*\\!40100 DEFAULT CHARACTER SET utf8 */;"\
    mysql -e "CREATE USER $\{MAINDB\}@localhost IDENTIFIED BY '$\{PASSWDDB\}';"\
    mysql -e "GRANT ALL PRIVILEGES ON $\{MAINDB\}.* TO '$\{MAINDB\}'@'localhost';"\
    mysql -e "FLUSH PRIVILEGES;"\
\
# If /root/.my.cnf doesn't exist then it'll ask for root password   \
else\
    echo "Please enter root user MySQL password!"\
    echo "Note: password will be hidden when typing"\
    read -sp rootpasswd\
    mysql -uroot -p$\{rootpasswd\} -e "CREATE DATABASE $\{MAINDB\} /*\\!40100 DEFAULT CHARACTER SET utf8 */;"\
    mysql -uroot -p$\{rootpasswd\} -e "CREATE USER $\{MAINDB\}@localhost IDENTIFIED BY '$\{PASSWDDB\}';"\
    mysql -uroot -p$\{rootpasswd\} -e "GRANT ALL PRIVILEGES ON $\{MAINDB\}.* TO '$\{MAINDB\}'@'localhost';"\
    mysql -uroot -p$\{rootpasswd\} -e "FLUSH PRIVILEGES;"\
fi\
\
sed -i 's/'database_name_here'/\{MAINDB\}/g; s/'password_here'/\{PASSWDDB\}/g; s/'username_here'/\{MAINDB\}/g' wp-config-sample.php\
echo "Please go to {\field{\*\fldinst{HYPERLINK "https://$url"}}{\fldrslt \cf3 https://$url}} and follow the setup prompts and when your done press anykey"\
read -r whatever\
$whatever; read -n 1 -p Continue?;\
find ./* -type d -exec chmod 775 \{\} + && systemctl restart httpd\
echo "Thank You for your patients your wordpress is installed and can be accessed at {\field{\*\fldinst{HYPERLINK "https://$url"}}{\fldrslt \cf3 https://$url}}\
echo -e\
sleep 0.2s\
echo -e\
echo "Have a nice day"}