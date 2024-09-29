#!/usr/bin/env bash
header_info() {
  clear
  cat <<"EOF"
    __ _______ ___  ______   ____             __     ____           __        ____
   / //_/ ___//   |/_  __/  / __ \____  _____/ /_   /  _/___  _____/ /_____ _/ / /
  / ,<  \__ \/ /| | / /    / /_/ / __ \/ ___/ __/   / // __ \/ ___/ __/ __ `/ / / 
 / /| |___/ / ___ |/ /    / ____/ /_/ (__  ) /_   _/ // / / (__  ) /_/ /_/ / / /  
/_/ |_/____/_/  |_/_/    /_/    \____/____/\__/  /___/_/ /_/____/\__/\__,_/_/_/ 

EOF
}
echo "Hello, please answer the following to automate your Hostname changes, enable root access to ssh and setup snmp."
sleep 0.8s
echo -e
echo -n "What is the host you wish to set your machine as?"
echo -e
read -r host
echo -e
echo  "What is your domain?"
read -r domain
echo -e
sleep 0.5s
echo -e
echo -n "What is the Community for snmp?"
echo -e
read -r community
echo -e
echo  "What is the name of your admin?"
read -r syscontactname
echo -e
echo -e
echo  "What is the Email of your admin?"
read -r syscontactemail
echo -e
echo  "What is the office location for your admin?"
read -r syscontactlocation
echo -e
sleep 0.5s
echo "Thank you processing your request this may take a moment"
sleep 0.5s
hostnamectl set-hostname $host.$domain
echo " Host is now set to $(hostname -s) and FQDN is $(hostname -f), now setting up SNMP please wait"
sleep 0.8s
mv /etc/snmp/snmpd.conf /etc/snmp/snmpd.conf_orig
echo "rocommunity $community" | tee -a /etc/snmp/snmpd.conf
echo "syscontact $syscontactname $syscontaceemail" | tee -a /etc/snmp/snmpd.conf
echo "syslocation $syscontactlocation" | tee -a /etc/snmp/snmpd.conf && systemctl enable snmpd
systemctl restart snmpd
sleep 0.8s
echo "Completed"
systemctl status snmpd
sleep 0.8s
echo "Now setting up SSH"
echo "PermitRootLogin yes" | tee -a /etc/ssh/sshd_config && systemctl restart sshd
echo -e
sleep 0.5s
echo "Process completed successfully your machine will now reboot"
sleep 0.5s
echo "Have a nice day"
sleep 0.5s
reboot now