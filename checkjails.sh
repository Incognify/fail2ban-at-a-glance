#!/usr/bin/env bash
# Enhanced Fail2Ban status checker
# Last update: March 4, 2025

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Default values
LOG_FILE="/var/log/fail2ban.log"
JAIL_CONF="/etc/fail2ban/jail.conf"
JAIL_LOCAL="/etc/fail2ban/jail.local"
MAX_TOP_IPS=5
DEFAULT_NUM_BANS=10

# Check if running with sudo/root privileges
check_privileges() {
  if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}This script needs to be run with sudo or as root.${NC}"
    exit 1
  fi
}

# Function to check if fail2ban is installed
check_fail2ban() {
  if ! command -v fail2ban-client &> /dev/null; then
    echo -e "${RED}Fail2Ban is not installed.${NC}"
    echo -e "${YELLOW}Would you like to install it? (y/n)${NC}"
    read -r install_choice
    if [[ "$install_choice" =~ ^[Yy]$ ]]; then
      apt-get update && apt-get install -y fail2ban
      echo -e "${GREEN}Fail2Ban installed successfully.${NC}"
    else
      echo -e "${RED}Exiting as Fail2Ban is required.${NC}"
      exit 1
    fi
  fi
}

# Function to get fail2ban status
get_fail2ban_status() {
  local status
  status=$(systemctl status fail2ban | grep Active | awk '{print $2}')
  if [ "$status" == "active" ]; then
    echo -e "${GREEN}ACTIVE${NC}"
  else
    echo -e "${RED}INACTIVE${NC}"
  fi
}

# Function to restart fail2ban
restart_fail2ban() {
  echo -e "${YELLOW}Restarting Fail2Ban...${NC}"
  systemctl restart fail2ban
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}Fail2Ban restarted successfully.${NC}"
  else
    echo -e "${RED}Failed to restart Fail2Ban.${NC}"
  fi
}

# Function to print header
print_header() {
  local title="$1"
  local width=${#title}
  local padding=$((width + 6))
  
  echo -e "${RED}"
  printf '%0.s#' $(seq 1 $padding)
  echo -e "\n# ${WHITE}$title${RED} #"
  printf '%0.s#' $(seq 1 $padding)
  echo -e "${NC}\n"
}

# Function to get jails from configuration
get_configured_jails() {
  if [ -f "$JAIL_LOCAL" ]; then
    grep "^\[.*\]$" "$JAIL_LOCAL" | grep -v "DEFAULT" | tr -d '[]'
  elif [ -f "$JAIL_CONF" ]; then
    grep "^\[.*\]$" "$JAIL_CONF" | grep -v "DEFAULT" | tr -d '[]'
  else
    echo "No jail configuration found."
  fi
}

# Function to get enabled jails
get_enabled_jails() {
  fail2ban-client status | grep "Jail list" | sed -E 's/^[^:]+:[ \t]+//' | sed 's/,//g'
}

# Function to show last N bans
show_last_bans() {
  local num="$1"
  if [ -z "$num" ]; then
    num="$DEFAULT_NUM_BANS"
  fi
  
  print_header "Last $num IP Bans"
  
  if [ -f "$LOG_FILE" ]; then
    zgrep 'Ban' "$LOG_FILE"* | tail -"$num" | while read -r line; do
      jail=$(echo "$line" | grep -oP '\[\K[^\]]+')
      ip=$(echo "$line" | grep -oP '(?<=Ban )[^ ]+')
      timestamp=$(echo "$line" | awk '{print $1, $2, $3}')
      
      if [ -n "$ip" ]; then
        echo -e "${CYAN}$timestamp${NC} - Jail: ${YELLOW}$jail${NC} - Banned IP: ${RED}$ip${NC}"
      fi
    done
  else
    echo -e "${RED}Log file not found: $LOG_FILE${NC}"
  fi
}

# Function to show jail status with extra info
show_jail_status() {
  print_header "Status Of All Enabled Fail2Ban Jails"
  
  echo -e "Fail2Ban Status: $(get_fail2ban_status)\n"
  
  local jails
  jails=$(get_enabled_jails)
  
  for jail in $jails; do
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WHITE}Jail:${NC} ${MAGENTA}$jail${NC}"
    
    # Get jail info
    local jail_info
    jail_info=$(fail2ban-client status "$jail")
    
    # Extract data
    local filter=$(echo "$jail_info" | grep "Filter:" | sed -E 's/^[^:]+:[ \t]+//')
    local logpath=$(echo "$jail_info" | grep "File list:" | sed -E 's/^[^:]+:[ \t]+//')
    local currentlyFailed=$(echo "$jail_info" | grep "Currently failed:" | sed -E 's/^[^:]+:[ \t]+//')
    local totalFailed=$(echo "$jail_info" | grep "Total failed:" | sed -E 's/^[^:]+:[ \t]+//')
    local bannedIPs=$(echo "$jail_info" | grep "Banned IP list:" | sed -E 's/^[^:]+:[ \t]+//')
    local findtime=$(echo "$jail_info" | grep "findtime:" | sed -E 's/^[^:]+:[ \t]+//')
    local bantime=$(echo "$jail_info" | grep "bantime:" | sed -E 's/^[^:]+:[ \t]+//')
    local maxretry=$(echo "$jail_info" | grep "maxretry:" | sed -E 's/^[^:]+:[ \t]+//')
    
    # Convert seconds to human-readable format
    if [ -n "$findtime" ]; then
      findtime_human=$(date -u -d @"$findtime" +"%H:%M:%S")
    else
      findtime_human="N/A"
    fi
    
    if [ -n "$bantime" ]; then
      if [ "$bantime" -gt 86400 ]; then
        bantime_human="$(($bantime / 86400)) days"
      elif [ "$bantime" -gt 3600 ]; then
        bantime_human="$(($bantime / 3600)) hours"
      elif [ "$bantime" -gt 60 ]; then
        bantime_human="$(($bantime / 60)) minutes"
      else
        bantime_human="$bantime seconds"
      fi
    else
      bantime_human="N/A"
    fi
    
    # Display jail info
    echo -e "${WHITE}Filter:${NC} $filter"
    echo -e "${WHITE}Log Path:${NC} $logpath"
    echo -e "${WHITE}Currently Failed:${NC} $currentlyFailed"
    echo -e "${WHITE}Total Failed:${NC} $totalFailed"
    echo -e "${WHITE}Findtime:${NC} $findtime_human"
    echo -e "${WHITE}Bantime:${NC} $bantime_human"
    echo -e "${WHITE}Max Retry:${NC} $maxretry"
    
    # Display banned IPs
    if [ -n "$bannedIPs" ] && [ "$bannedIPs" != "" ]; then
      echo -e "${WHITE}Banned IPs (${NC}${RED}$(echo "$bannedIPs" | wc -w)${NC}${WHITE}):${NC} ${RED}$bannedIPs${NC}"
    else
      echo -e "${WHITE}Banned IPs:${NC} ${GREEN}None${NC}"
    fi
  done
}

# Function to show bans for specific jail
show_jail_bans() {
  local specific_jail="$1"
  
  if [ -z "$specific_jail" ]; then
    # Display available jails for selection
    echo -e "${YELLOW}Available jails:${NC}"
    local jails
    jails=$(get_enabled_jails)
    local jail_array=()
    local i=1
    
    for jail in $jails; do
      echo -e "${WHITE}$i)${NC} $jail"
      jail_array+=("$jail")
      ((i++))
    done
    
    read -p "Select jail number: " jail_num
    if [ "$jail_num" -gt 0 ] && [ "$jail_num" -le "${#jail_array[@]}" ]; then
      specific_jail="${jail_array[jail_num-1]}"
    else
      echo -e "${RED}Invalid selection.${NC}"
      return
    fi
  fi
  
  print_header "Banned IPs for $specific_jail"
  
  local jail_info
  jail_info=$(fail2ban-client status "$specific_jail")
  local bannedIPs=$(echo "$jail_info" | grep "Banned IP list:" | sed -E 's/^[^:]+:[ \t]+//')
  
  if [ -n "$bannedIPs" ] && [ "$bannedIPs" != "" ]; then
    local count=0
    for ip in $bannedIPs; do
      ((count++))
      echo -e "${WHITE}$count)${NC} ${RED}$ip${NC}"
      
      # Get ban time from logs
      local ban_time=$(zgrep "Ban $ip" "$LOG_FILE"* | grep "$specific_jail" | tail -1 | awk '{print $1, $2, $3}')
      if [ -n "$ban_time" ]; then
        echo -e "   ${CYAN}Banned at: $ban_time${NC}"
      fi
    done
  else
    echo -e "${GREEN}No IPs are currently banned in this jail.${NC}"
  fi
}

# Function to unban an IP
unban_ip() {
  local ip_to_unban="$1"
  local jail_to_unban="$2"
  
  if [ -z "$ip_to_unban" ]; then
    read -p "Enter IP to unban: " ip_to_unban
  fi
  
  if [ -z "$jail_to_unban" ]; then
    # Display available jails for selection
    echo -e "${YELLOW}Available jails:${NC}"
    local jails
    jails=$(get_enabled_jails)
    local jail_array=()
    local i=1
    
    for jail in $jails; do
      echo -e "${WHITE}$i)${NC} $jail"
      jail_array+=("$jail")
      ((i++))
    done
    
    read -p "Select jail number to unban from (0 for all): " jail_num
    
    if [ "$jail_num" -eq 0 ]; then
      # Unban from all jails
      for jail in $jails; do
        fail2ban-client set "$jail" unbanip "$ip_to_unban"
      done
      echo -e "${GREEN}IP $ip_to_unban unbanned from all jails.${NC}"
    elif [ "$jail_num" -gt 0 ] && [ "$jail_num" -le "${#jail_array[@]}" ]; then
      jail_to_unban="${jail_array[jail_num-1]}"
      fail2ban-client set "$jail_to_unban" unbanip "$ip_to_unban"
      echo -e "${GREEN}IP $ip_to_unban unbanned from $jail_to_unban.${NC}"
    else
      echo -e "${RED}Invalid selection.${NC}"
    fi
  else
    fail2ban-client set "$jail_to_unban" unbanip "$ip_to_unban"
    echo -e "${GREEN}IP $ip_to_unban unbanned from $jail_to_unban.${NC}"
  fi
}

# Function to display fail2ban configuration
show_configuration() {
  print_header "Fail2Ban Configuration"
  
  echo -e "${WHITE}Fail2Ban Version:${NC} $(fail2ban-client --version)"
  echo -e "${WHITE}Service Status:${NC} $(get_fail2ban_status)"
  
  # Show paths to config files
  echo -e "\n${YELLOW}Configuration Files:${NC}"
  echo -e "${WHITE}Main Configuration:${NC} /etc/fail2ban/fail2ban.conf"
  echo -e "${WHITE}Jail Configuration:${NC} /etc/fail2ban/jail.conf"
  
  if [ -f "$JAIL_LOCAL" ]; then
    echo -e "${WHITE}Local Jail Configuration:${NC} $JAIL_LOCAL ${GREEN}(Active)${NC}"
  fi
  
  # Show enabled jails vs configured jails
  echo -e "\n${YELLOW}Jail Statistics:${NC}"
  local enabled_jails
  enabled_jails=$(get_enabled_jails)
  local configured_jails
  configured_jails=$(get_configured_jails)
  
  echo -e "${WHITE}Configured Jails:${NC} $(echo "$configured_jails" | wc -w)"
  echo -e "${WHITE}Enabled Jails:${NC} $(echo "$enabled_jails" | wc -w)"
}

# Function to ban an IP manually
ban_ip_manually() {
  local ip_to_ban="$1"
  local jail_to_ban="$2"
  
  if [ -z "$ip_to_ban" ]; then
    read -p "Enter IP to ban: " ip_to_ban
  fi
  
  if [ -z "$jail_to_ban" ]; then
    # Display available jails for selection
    echo -e "${YELLOW}Available jails:${NC}"
    local jails
    jails=$(get_enabled_jails)
    local jail_array=()
    local i=1
    
    for jail in $jails; do
      echo -e "${WHITE}$i)${NC} $jail"
      jail_array+=("$jail")
      ((i++))
    done
    
    read -p "Select jail number to ban from: " jail_num
    
    if [ "$jail_num" -gt 0 ] && [ "$jail_num" -le "${#jail_array[@]}" ]; then
      jail_to_ban="${jail_array[jail_num-1]}"
      fail2ban-client set "$jail_to_ban" banip "$ip_to_ban"
      echo -e "${GREEN}IP $ip_to_ban banned in $jail_to_ban.${NC}"
    else
      echo -e "${RED}Invalid selection.${NC}"
    fi
  else
    fail2ban-client set "$jail_to_ban" banip "$ip_to_ban"
    echo -e "${GREEN}IP $ip_to_ban banned in $jail_to_ban.${NC}"
  fi
}

# Function to show top offenders (IPs with most bans)
show_top_offenders() {
  local num="$1"
  if [ -z "$num" ]; then
    num="$MAX_TOP_IPS"
  fi
  
  print_header "Top $num Offenders (Most Banned IPs)"
  
  if [ -f "$LOG_FILE" ]; then
    zgrep 'Ban' "$LOG_FILE"* | grep -oP '(?<=Ban )[^ ]+' | sort | uniq -c | sort -nr | head -"$num" | while read -r count ip; do
      # Get jails where this IP was banned
      local jails=$(zgrep "Ban $ip" "$LOG_FILE"* | grep -oP '\[\K[^\]]+' | sort | uniq | tr '\n' ',' | sed 's/,$//')
      
      echo -e "${WHITE}IP:${NC} ${RED}$ip${NC} - ${WHITE}Ban Count:${NC} ${RED}$count${NC}"
      echo -e "${WHITE}Jails:${NC} ${YELLOW}$jails${NC}"
      
      # Get country info if geoiplookup is available
      if command -v geoiplookup &> /dev/null; then
        local country=$(geoiplookup "$ip" | grep Country | sed 's/.*: //')
        echo -e "${WHITE}Location:${NC} $country"
      elif command -v whois &> /dev/null; then
        local country=$(whois "$ip" | grep -i "country" | head -1 | awk '{print $2}')
        if [ -n "$country" ]; then
          echo -e "${WHITE}Country Code:${NC} $country"
        fi
      fi
      
      echo ""
    done
  else
    echo -e "${RED}Log file not found: $LOG_FILE${NC}"
  fi
}

# Function to show jail activity graph
show_jail_activity() {
  print_header "Jail Activity (Last 24 Hours)"
  
  if [ -f "$LOG_FILE" ]; then
    local jails
    jails=$(get_enabled_jails)
    
    for jail in $jails; do
      local ban_count=$(zgrep "Ban" "$LOG_FILE"* | grep "\[$jail\]" | wc -l)
      local bar_length=$((ban_count / 5))
      if [ "$bar_length" -gt 50 ]; then
        bar_length=50
      fi
      
      printf "${MAGENTA}%-15s${NC} [" "$jail"
      for ((i=0; i<bar_length; i++)); do
        printf "${RED}#${NC}"
      done
      for ((i=bar_length; i<50; i++)); do
        printf " "
      done
      printf "] ${WHITE}%3d${NC}\n" "$ban_count"
    done
  else
    echo -e "${RED}Log file not found: $LOG_FILE${NC}"
  fi
}

# Function to export ban lists
export_ban_lists() {
  local export_file="/tmp/fail2ban_export_$(date +%Y%m%d_%H%M%S).txt"
  
  print_header "Exporting Ban Lists"
  
  echo -e "Fail2Ban Ban Lists - $(date)" > "$export_file"
  echo -e "================================\n" >> "$export_file"
  
  local jails
  jails=$(get_enabled_jails)
  
  for jail in $jails; do
    echo -e "Jail: $jail" >> "$export_file"
    local banned_ips=$(fail2ban-client status "$jail" | grep "Banned IP list:" | sed -E 's/^[^:]+:[ \t]+//')
    
    if [ -n "$banned_ips" ] && [ "$banned_ips" != "" ]; then
      echo -e "Banned IPs: $banned_ips" >> "$export_file"
    else
      echo -e "Banned IPs: None" >> "$export_file"
    fi
    
    echo -e "--------------------------------\n" >> "$export_file"
  done
  
  echo -e "${GREEN}Ban lists exported to: $export_file${NC}"
  cat "$export_file"
}

# Function to check fail2ban resource usage
check_resource_usage() {
  print_header "Fail2Ban Resource Usage"
  
  # Check process info
  local pid=$(pgrep -f "fail2ban-server" | head -1)
  
  if [ -n "$pid" ]; then
    echo -e "${WHITE}Process ID:${NC} $pid"
    
    # CPU and memory usage
    echo -e "${WHITE}CPU & Memory Usage:${NC}"
    ps -p "$pid" -o pid,ppid,cmd,%cpu,%mem,rss | head -1
    ps -p "$pid" -o pid,ppid,cmd,%cpu,%mem,rss | grep -v PID
    
    # Log file size
    echo -e "\n${WHITE}Log File Size:${NC}"
    du -h "$LOG_FILE"* | sort -hr
    
    # Database file size (if exists)
    if [ -f /var/lib/fail2ban/fail2ban.sqlite3 ]; then
      echo -e "\n${WHITE}Database File Size:${NC}"
      du -h /var/lib/fail2ban/fail2ban.sqlite3
    fi
  else
    echo -e "${RED}Fail2Ban server process not found.${NC}"
  fi
}

# Function to print menu
print_menu() {
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${GREEN}FAIL2BAN AT A GLANCE${NC} - Status: $(get_fail2ban_status)"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${WHITE}1.${NC} Show last N IP bans"
  echo -e "${WHITE}2.${NC} Show status of all enabled jails"
  echo -e "${WHITE}3.${NC} Show bans for a specific jail"
  echo -e "${WHITE}4.${NC} Unban an IP"
  echo -e "${WHITE}5.${NC} Ban an IP manually"
  echo -e "${WHITE}6.${NC} Show top offenders"
  echo -e "${WHITE}7.${NC} Show jail activity graph"
  echo -e "${WHITE}8.${NC} Show fail2ban configuration"
  echo -e "${WHITE}9.${NC} Export ban lists"
  echo -e "${WHITE}10.${NC} Check resource usage"
  echo -e "${WHITE}11.${NC} Restart fail2ban service"
  echo -e "${WHITE}12.${NC} Exit"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Main
check_privileges
check_fail2ban
clear
echo -e "${GREEN}Welcome to Fail2Ban at a Glance${NC}"

# Main loop
while true; do
  print_menu
  read -p "Choose an option: " choice
  
  case $choice in
    1)
      read -p "How many last bans to display? [$DEFAULT_NUM_BANS]: " num
      [ -z "$num" ] && num="$DEFAULT_NUM_BANS"
      clear
      show_last_bans "$num"
      ;;
    2)
      clear
      show_jail_status
      ;;
    3)
      clear
      show_jail_bans
      ;;
    4)
      clear
      unban_ip
      ;;
    5)
      clear
      ban_ip_manually
      ;;
    6)
      read -p "How many top offenders to display? [$MAX_TOP_IPS]: " num
      [ -z "$num" ] && num="$MAX_TOP_IPS"
      clear
      show_top_offenders "$num"
      ;;
    7)
      clear
      show_jail_activity
      ;;
    8)
      clear
      show_configuration
      ;;
    9)
      clear
      export_ban_lists
      ;;
    10)
      clear
      check_resource_usage
      ;;
    11)
      clear
      restart_fail2ban
      ;;
    12)
      echo -e "${GREEN}Exiting.${NC}"
      exit 0
      ;;
    *)
      echo -e "${RED}Invalid option.${NC}"
      ;;
  esac
  
  echo
  read -p "Press Enter to continue..."
  clear
done
