#!/bin/bash
# Enhanced Fail2Ban status checker
# Updated 10/08/2023

# Function to print menu
menu() {
  echo "1. Show last N IP bans"
  echo "2. Show status of all enabled jails"
  echo "3. Show bans for a specific jail"
  echo "4. Unban an IP"
  echo "5. Exit"
}

# Main loop
while true; do
  menu
  read -p "Choose an option: " choice

  case $choice in
    1)
      read -p "How many last bans to display? " num
      echo "####################"
      echo "# Last $num IP Bans: #"
      echo "####################"
      sudo zgrep 'Ban' /var/log/fail2ban.log* | tail -"$num"
      ;;
    2)
      echo "##########################################"
      echo "# Status Of All Enabled Fail2Ban Jails:  #"
      echo "##########################################"
      JAILS=$(sudo fail2ban-client status | grep "Jail list" | sed -E 's/^[^:]+:[ \t]+//' | sed 's/,//g')
      for JAIL in $JAILS; do
        sudo fail2ban-client status "$JAIL"
      done
      ;;
    3)
      read -p "Which jail's bans would you like to see? " specific_jail
      echo "Banned IPs for $specific_jail:"
      sudo fail2ban-client status "$specific_jail" | grep "Banned IP list" | sed -E 's/^[^:]+:[ \t]+//'
      ;;
    4)
      read -p "Enter IP to unban: " ip_to_unban
      read -p "Enter jail to remove IP from: " jail_to_unban
      sudo fail2ban-client set "$jail_to_unban" unbanip "$ip_to_unban"
      echo "IP $ip_to_unban unbanned from $jail_to_unban."
      ;;
    5)
      echo "Exiting."
      exit 0
      ;;
    *)
      echo "Invalid option."
      ;;
  esac
done
