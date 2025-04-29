#!/bin/bash

# Define color codes
GREEN='\033[0;92m'      # Bright Green
BLUE='\033[0;94m'       # Bright Blue
CYAN='\033[0;96m'       # Bright Cyan
YELLOW='\033[0;93m'     # Bright Yellow
RED='\033[0;91m'        # Bright Red
PURPLE='\033[0;95m'     # Bright Purple
NC='\033[0m'            # No Color - Resets the color back to default

check_root() {
  if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}This script must be run as root.${NC}"
    exit 1
  fi
}

check_dependency() {
  clear
  echo -e "${BLUE}Checking dependency...${NC}\n"
  sleep 2
  if command -v nmcli >/dev/null 2>&1; then
    echo -e "${GREEN}NetworkManager is installed.${NC}\n"
  else
    echo -e "${RED}NetworkManager is not installed. Exiting...${NC}\n"
    exit 1
  fi
}

restart_network_manager() {
  echo -e "${GREEN}Restarting NetworkManager....${NC}\n"
  if command -v systemctl >/dev/null 2>&1; then
    systemctl restart NetworkManager
  elif command -v sv >/dev/null 2>&1; then
    sv restart NetworkManager
  elif command -v service >/dev/null 2>&1; then
    service NetworkManager restart
  else
    echo -e "${RED}No recognized Init System found. Please restart NetworkManager manually.${NC}"
    exit 1
  fi
}

main() {
  check_root
  check_dependency
  echo -e "${YELLOW}Creating config file (${CYAN}/etc/NetworkManager/conf.d/wifi_rand_mac.conf${YELLOW})....${NC}\n"
  echo -e "${GREEN}Writing the settings to the config file....${NC}\n"
  cat > /etc/NetworkManager/conf.d/wifi_rand_mac.conf << EOF
[device-mac-randomization]
wifi.scan-rand-mac-address=yes
[connection-mac-randomization]
ethernet.cloned-mac-address=random
wifi.cloned-mac-address=random
EOF
  restart_network_manager
  echo -e "${GREEN}The script has executed successfully. Your MAC address will change every time you reconnect to a network, making your device appear as a new one each time!${NC}"
}

main
