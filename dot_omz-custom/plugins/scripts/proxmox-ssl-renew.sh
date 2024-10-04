#!/usr/bin/bash
<<Header
Script:   ssl-renew.sh
Date:     12.01.2021
Author:   the-technat
Version:  1.0
History   User    Date        Change
          technat 12.01.2021  initial version
Description: update ssl cert from Let's Encrypt using certbot and copy certs for use with pveproxy
Cronjob: 0 5 1 * * /root/ssl-renew.sh
Dependency: certbot, pveproxy

© the-technat

Header

#############################################################################
################################# Variables #################################
#############################################################################

# general
domain='yourdomain.com'
logfile='/var/log/ssl-renew.log'
rule='IN ACCEPT -i vmbr0 -dest 1.2.3.4 -p tcp -dport 80 -log nolog'

#############################################################################
############################### Preparations ################################
#############################################################################

# certbot is installed
which certbot
if [[ ! $? -eq 0 ]]; then
    sudo apt install certbot -y
fi

# open port 80 on proxmox firewall
sed -i "/\[RULES\]/a $rule" /etc/pve/firewall/cluster.fw
sudo pve-firewall stop
sudo pve-firewall start

#############################################################################
################################ Main Script ################################
#############################################################################

# renew cert
/usr/bin/certbot renew >> $logfile 

# delete the old cert
rm -rf /etc/pve/local/pve-ssl.pem
rm -rf /etc/pve/local/pve-ssl.key
rm -rf /etc/pve/pve-root-ca.pem

# copy the renewed one to the correct location
cp /etc/letsencrypt/live/$domain/fullchain.pem /etc/pve/local/pve-ssl.pem
cp /etc/letsencrypt/live/$domain/privkey.pem /etc/pve/local/pve-ssl.key
cp /etc/letsencrypt/live/$domain/chain.pem /etc/pve/pve-root-ca.pem

#############################################################################
################################## Cleanup ##################################
#############################################################################

# close port 80 on proxmox firewall
sed -i "s/$rule//g" /etc/pve/firewall/cluster.fw
sudo pve-firewall stop
sudo pve-firewall start

# postprocessing - restart pveproxy
systemctl restart pveproxy


