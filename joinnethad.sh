#!/usr/bin/env bash

echo -e
echo  "Please enter the password for admin"
echo -e
wait
read -r adpass

echo -e
echo  "Please enter your domain name"
echo -e
wait
read -r domain

#Updating file /etc/hosts

echo "127.0.0.1 localhost
::1             localhost ip6-localhost ip6-loopback
ff02::1         ip6-allnodes
ff02::2         ip6-allrouters

127.0.1.1               $(cat /etc/hostname).$domain $(cat /etc/hostname)" > /etc/hosts

#Updating file /etc/sudoers

grep -qxF '%domain\ admins ALL=(ALL:ALL) ALL' /etc/sudoers || echo '%domain\ admins ALL=(ALL:ALL) ALL' >> /etc/sudoers

#Updating RPI

sudo apt -y update

#Installing krb-user

export DEBIAN_FRONTEND=noninteractive
sudo -E apt -y -qq install krb5-user
wait

#Updating file /etc/krb5.conf

echo "[libdefaults]
        default_realm = AD.${domain^^}


[login]
        krb4_convert = true
        krb4_get_tickets = false" > /etc/krb5.conf

#Installing libpam-sss

export DEBIAN_FRONTEND=noninteractive
sudo -E apt -y -qq install libpam-sss
wait

#Installing libpam-mount


export DEBIAN_FRONTEND=noninteractive
sudo -E apt -y -qq install libpam-mount
wait

#Updating file /etc/pam.d/common-session

echo "#
# /etc/pam.d/common-session - session-related modules common to all services
#
# This file is included from other service-specific PAM config files,
# and should contain a list of modules that define tasks to be performed
# at the start and end of sessions of *any* kind (both interactive and
# non-interactive).
#
# As of pam 1.0.1-6, this file is managed by pam-auth-update by default.
# To take advantage of this, it is recommended that you configure any
# local modules either before or after the default block, and use
# pam-auth-update to manage selection of other modules.  See
# pam-auth-update(8) for details.

# here are the per-package modules (the "Primary" block)
session [default=1]                     pam_permit.so
# here's the fallback if no module succeeds
session requisite                       pam_deny.so
# prime the stack with a positive return value if there isn't one already;
# this avoids us returning an error just because nothing sets a success code
# since the modules above will each just jump around
session required                        pam_permit.so
# and here are more per-package modules (the "Additional" block)
session required        pam_unix.so 
session optional                        pam_sss.so 
session optional        pam_systemd.so 
session optional        pam_chksshpwd.so 
session required pam_mkhomedir.so skel=/etc/skel/ umask=0022


# end of pam-auth-update config" > /etc/pam.d/common-session

#Installing realmd

export DEBIAN_FRONTEND=noninteractive
sudo -E apt -y -qq install realmd
wait

#Updating file /etc/realmd.conf

echo "[active-directory]
os-name = Raspbian
os-version = $(cat /etc/debian_version)

[service]
automatic-install = yes

[users]
default-home = /home/%u
default-shell = /bin/bash

[ad.$domain]
user-principal = yes
fully-qualified-names = no" > /etc/realmd.conf

#Installing Prerequisites
sudo apt -y install ntp python3-pip sssd adcli libsss-sudo cifs-utils smbclient sssd-tools samba-common packagekit samba-common-bin samba-libs libnss-sss oddjob oddjob-mkhomedir packagekit

wait

#Updating file /etc/sssd/sssd.conf

echo "[sssd]
domains =
config_file_version = 2
services = nss, pam

[$domain/ad.$domain]
ad_domain = ad.$domain
krb5_realm = AD.${domain^^}
realmd_tags = manages-system joined-with-adcli
cache_credentials = True
id_provider = ad
krb5_store_password_if_offline = True
default_shell = /bin/bash
ldap_id_mapping = True
use_fully_qualified_names = True
fallback_homedir = /home/%u
access_provider = ad

auth_provider = ad
chpass_provider = ad
access_provider = ad
ldap_schema = ad
dyndns_update = true
dyndns_refresh_interval = 43200
dyndns_update_ptr = true
dyndns_ttl = 3600" > /etc/sssd/sssd.conf



#Updating file /etc/ntp.conf

echo "# /etc/ntp.conf, configuration for ntpd; see ntp.conf(5) for help

driftfile /var/lib/ntp/ntp.drift

# Leap seconds definition provided by tzdata
leapfile /usr/share/zoneinfo/leap-seconds.list

# Enable this if you want statistics to be logged.
#statsdir /var/log/ntpstats/

statistics loopstats peerstats clockstats
filegen loopstats file loopstats type day enable
filegen peerstats file peerstats type day enable
filegen clockstats file clockstats type day enable


# You do need to talk to an NTP server or two (or three).
server time.cloudflare.com

# pool.ntp.org maps to about 1000 low-stratum NTP servers.  Your server will
# pick a different set every time it starts up.  Please consider joining the
# pool: <http://www.pool.ntp.org/join.html>
pool 0.debian.pool.ntp.org iburst
pool 1.debian.pool.ntp.org iburst
pool 2.debian.pool.ntp.org iburst
pool 3.debian.pool.ntp.org iburst


# Access control configuration; see /usr/share/doc/ntp-doc/html/accopt.html for
# details.  The web page <http://support.ntp.org/bin/view/Support/AccessRestrictions>
# might also be helpful.
#
# Note that "restrict" applies to both servers and clients, so a configuration
# that might be intended to block requests from certain clients could also end
# up blocking replies from your own upstream servers.

# By default, exchange time with everybody, but don't allow configuration.
restrict -4 default kod notrap nomodify nopeer noquery limited
restrict -6 default kod notrap nomodify nopeer noquery limited

# Local users may interrogate the ntp server more closely.
restrict 127.0.0.1
restrict -6 ::1

# Needed for adding pool entries
restrict source notrap nomodify noquery

# Clients from this (example!) subnet have unlimited access, but only if
# cryptographically authenticated.
#restrict 192.168.123.0 mask 255.255.255.0 notrust


# If you want to provide time to your local subnet, change the next line.
# (Again, the address is an example only.)
#broadcast 192.168.123.255

# If you want to listen to time broadcasts on your local subnet, de-comment the
# next lines.  Please do this only if you trust everybody on the network!
#disable auth
#broadcastclient" > /etc/ntp.conf

#Restarting the NTP service

sudo systemctl restart ntp

#Discovering Realm

realm discover ad.$domain

echo "$adpass" | kinit -V admin

#Joining domain

echo "$adpass" | realm join -U admin@AD.${domain^^} ad.$domain

wait

echo -e
echo  "Congratulations $(cat /etc/hostname) is now part of ad.$domain"
echo -e
