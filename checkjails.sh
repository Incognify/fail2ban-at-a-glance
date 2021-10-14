#!/bin/bash
# Checks Fail2Ban's latest IP blocks and jail status
echo "####################"
echo "# Last 20 IP Bans: #"
echo "####################"
sudo zgrep 'Ban' /var/log/fail2ban.log* | tail -20
echo "##########################################"
echo "# Status Of All Enabled Fail2Ban Jails:  #"
echo "##########################################"
JAILS=`sudo fail2ban-client status | grep "Jail list" | sed -E 's/^[^:]+:[ \t]+//' | sed 's/,//g'`
for JAIL in $JAILS
do
  sudo fail2ban-client status $JAIL
done
