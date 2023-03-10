#!/bin/bash

INSTALL_DIR="/home/pos/quikserve"
INSTALL_USER="pos"

mkdir -p $INSTALL_DIR

# enter overseer url
read -p "Overseer URL: " OVERSEER_URL

# enter short code
read -p "Short Code: " SHORT_CODE

# select pos options
echo -e "POS Options\n"
read -p "Leader (y/N): " LEADER
read -p "Enable Customer Display (y/N): " CUSTOMER_DISPLAY
read -p "Fullscreen (Y/n): " FULLSCREEN
read -p "Demo Mode (y/N): " DEMO_MODE
read -p "Memory Mode (y/N): " MEMORY_MODE

# reach out to overseer to get token from short code

# reach out to overseer to get pos binary

# could setup auto-updates?

chown -R $INSTALL_USER:$INSTALL_USER $INSTALL_DIR