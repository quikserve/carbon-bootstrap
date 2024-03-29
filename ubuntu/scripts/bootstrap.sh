#!/bin/bash

echo "QuikServe Solutions"
echo "Setup will now begin..."
echo -e "\n\nPlease be patient as this may take a few minutes.\n\n"

echo "127.0.0.1 $(hostname)" | sudo tee -a /etc/hosts >/dev/null

function check_internet {
    echo "Checking internet connection..."
    wget -q --tries=10 --timeout=20 --spider http://google.com
    if [[ $? -eq 0 ]]; then
        echo "Internet connection detected."
    else
        echo "No internet connection detected. Please connect to the internet. Retrying in 10 seconds..."
        sleep 10
        check_internet 
    fi
}
check_internet

sleep 5

# Detect hardware

# Install base dependencies

# Temporary dist upgrade as autoinstaller has issues with 22.04, but thats what we want
# Hopefully 22.04 resolves this issue and we can remove this and install 22.04 directly
# This issue may provide updates: https://bugs.launchpad.net/subiquity/+bug/2000470
version=$(lsb_release -sr)
if [ $version == "20.04" ]; then
  sudo DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a do-release-upgrade -f DistUpgradeViewNonInteractive
fi

sudo apt update && sudo NEEDRESTART_MODE=a DEBIAN_FRONTEND=noninteractive apt upgrade -y
sudo NEEDRESTART_MODE=a DEBIAN_FRONTEND=noninteractive apt install -y ubuntu-desktop-minimal dbus-x11 jq tigervnc-scraping-server
sudo DEBIAN_FRONTEND=noninteractive apt remove --autoremove gnome-initial-setup

# Setup security updates automatic

# Install/configure hardware specific dependencies

# Setup pos user
if ! id -u "pos" >/dev/null 2>&1; then
  sudo useradd -m pos -s /bin/bash
  echo "pos:quikserve" | sudo chpasswd
  sudo sed -i 's/#  AutomaticLoginEnable = true/AutomaticLoginEnable=true/g' /etc/gdm3/custom.conf
  sudo sed -i 's/#  AutomaticLogin = user1/AutomaticLogin=pos/g' /etc/gdm3/custom.conf
  sudo sed -i 's/#WaylandEnable=false/WaylandEnable=false/g' /etc/gdm3/custom.conf
fi

# Install POS
wget -qO carbon.sh https://raw.githubusercontent.com/quikserve/carbon-bootstrap/master/carbon/install.sh
chmod +x carbon.sh
sudo ./carbon.sh < /dev/tty

# Install login script
wget -qO /home/pos/post_login.sh https://raw.githubusercontent.com/quikserve/carbon-bootstrap/master/ubuntu/scripts/post_login.sh
chmod +x /home/pos/post_login.sh
chown pos:pos /home/pos/post_login.sh

sudo mkdir -p /home/pos/.config/autostart
echo "[Desktop Entry]
Type=Application
Exec=/home/pos/post_login.sh
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name[en_US]=Post Login
Name=Post Login
Comment[en_US]=
Comment=" | sudo tee /home/pos/.config/autostart/post_login.desktop >/dev/null
sudo chown -R pos:pos /home/pos/.config

# Setup VNC
sudo mkdir -p /home/pos/.vnc
echo "quikserve" | sudo vncpasswd -f > /home/pos/.vnc/passwd
sudo chown -R pos:pos /home/pos/.vnc
sudo chmod 0600 /home/pos/.vnc/passwd

# Remove autologin for setup
sudo rm /etc/systemd/system/getty@tty1.service.d/override.conf

sudo reboot