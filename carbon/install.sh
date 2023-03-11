#!/bin/bash

INSTALL_DIR="/home/pos/quikserve"
INSTALL_USER="pos"

mkdir -p $INSTALL_DIR

# enter overseer url
read -p "Overseer URL: " OVERSEER_URL

# enter install code
read -p "Install Code: " SHORT_CODE

# reach out to overseer to get token from short code
TOKEN=$(curl -s --request GET \
  --url $OVERSEER_URL/api/location-token/$SHORT_CODE | jq -r '.carbonToken')

echo -e "\nCarbon Token: ${TOKEN}\n"

# reach out to overseer to get pos binary
wget --header="Authorization: Basic ${TOKEN}" -qO $INSTALL_DIR/pos $OVERSEER_URL/api/carbon/dist/pos/linux_x86
chmod +x $INSTALL_DIR/pos

# select pos options
echo -e "POS Options\n"
read -p "Leader (y/N): " LEADER
read -p "Enable Customer Display (y/N): " CUSTOMER_DISPLAY
read -p "Fullscreen (Y/n): " FULLSCREEN
read -p "Demo Mode (y/N): " DEMO_MODE
read -p "Memory Mode (y/N): " MEMORY_MODE

# could setup auto-updates?

chown -R $INSTALL_USER:$INSTALL_USER $INSTALL_DIR