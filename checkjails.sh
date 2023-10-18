#!/bin/bash
# Enhanced Fail2Ban status checker
# Last update 10/18/2023 - Still more to do.

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

clear
echo -e "${GREEN}Welcome to Fail2Ban at a Glance${NC}"

# Function to print menu
menu() {
  echo "----------------------------------"
  echo "1. Show last N IP bans"
  echo "2. Show status of all enabled jails"
  echo "3. Show bans for a specific jail"
  echo "4. Unban an IP"
  echo "5. AbuseIPDB Stats"
  echo "6. Exit"
  echo "----------------------------------"
}

# Main loop
while true; do
  menu
  read -p "Choose an option: " choice

  case $choice in
    1)
      read -p "How many last bans to display? " num
      echo -e "${RED}#####################${NC}"
      echo -e "${RED}# Last $num IP Bans: #${NC}"
      echo -e "${RED}#####################${NC}"
      sudo zgrep 'Ban' /var/log/fail2ban.log* | tail -"$num"
      ;;
    2)
      echo -e "${RED}#############################################${NC}"
      echo -e "${RED}# Status Of All Enabled Fail2Ban Jails:     #${NC}"
      echo -e "${RED}#############################################${NC}"
      JAILS=$(sudo fail2ban-client status | grep "Jail list" | sed -E 's/^[^:]+:[ \t]+//' | sed 's/,//g')
      for JAIL in $JAILS; do
        sudo fail2ban-client status "$JAIL" | awk '
          /Status for/ {print "\033[0;32m" $0 "\033[0m"}
          /Banned IP list/ {print "\033[0;31m" $0 "\033[0m"}
          !/Status for|Banned IP list/ {print $0}
        '
      done
      ;;
    3)
      read -p "Which jail's bans would you like to see? " specific_jail
      echo -e "${RED}Banned IPs for $specific_jail:${NC}"
      sudo fail2ban-client status "$specific_jail" | grep "Banned IP list" | sed -E 's/^[^:]+:[ \t]+//'
      ;;
    4)
      read -p "Enter IP to unban: " ip_to_unban
      read -p "Enter jail to remove IP from: " jail_to_unban
      sudo fail2ban-client set "$jail_to_unban" unbanip "$ip_to_unban"
      echo -e "${GREEN}IP $ip_to_unban unbanned from $jail_to_unban.${NC}"
      ;;
    5)
      if [ -e /etc/fail2ban/action.d/report-abuseipdb.conf ]; then
        total_ips=$(wc -l < /var/log/abuseipdb_reports.log)
        last_ip_date=$(tail -n 1 /var/log/abuseipdb_reports.log | awk '{print $NF}')
        echo "###############################"
        echo "# AbuseIPDB Reporting Stats:  #"
        echo "###############################"
        echo "Total number of IPs reported to AbuseIPDB: $total_ips"
        echo "Last reported on: $last_ip_date"
      else
      #The below section is useless right now but I'll write up a guie sooner or later.
      	echo "#########################################"
        echo "# AbuseIPDB Reporting is NOT ENABLED!   #"
        echo "#########################################"
        echo "Please enable it by following the guide:"
        echo "https://example.com"
      fi
      ;;
    6)
      echo -e "${GREEN}Exiting.${NC}"
      exit 0
      ;;
    *)
      echo -e "${RED}Invalid option.${NC}"
      ;;
  esac
done
