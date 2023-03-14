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
read -p "Port (default: auto): " PORT
read -p "Enable Customer Display (y/N): " CUSTOMER_DISPLAY
read -p "KVS Mode (y/N): " KVS_MODE
read -p "Fullscreen (Y/n): " FULLSCREEN
read -p "Demo Mode (y/N): " DEMO_MODE
read -p "Memory Mode (y/N): " MEMORY_MODE

# could setup auto-updates?

FLAGS=""

if [ "$LEADER" == "y" ]; then
  FLAGS+="--leader"
fi

if [ "$PORT" != "" ]; then
  FLAGS+=" --port $PORT"
fi

if [ "$CUSTOMER_DISPLAY" == "y" ]; then
  FLAGS+=" --cust_disp"
fi

if [ "$KVS_MODE" == "y" ]; then
  FLAGS+=" --kvs"
fi

if [ "$FULLSCREEN" != "n" ]; then
  FLAGS+=" --fullscreen"
fi

if [ "$DEMO_MODE" == "y" ]; then
  FLAGS+=" --demo"
fi

if [ "$MEMORY_MODE" == "y" ]; then
  FLAGS+=" --memory"
fi

echo -e "\nPOS Flags: ${FLAGS}\n"
FLAGS=$(echo $FLAGS | xargs)

chown -R $INSTALL_USER:$INSTALL_USER $INSTALL_DIR

mkdir -p /home/$INSTALL_USER/.config/autostart
echo "[Desktop Entry]
Type=Application
Exec=${INSTALL_DIR}/pos ${FLAGS}
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name[en_US]=POS
Name=POS
Comment[en_US]=
Comment=" | sudo tee /home/$INSTALL_USER/.config/autostart/pos.desktop >/dev/null
sudo chown -R $INSTALL_USER:$INSTALL_USER /home/$INSTALL_USER/.config
