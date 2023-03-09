#!/bin/bash

echo "QuikServe Solutions"
echo "Setup will now begin..."
echo "\n\nPlease be patient as this may take a few minutes.\n\n"

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
  sudo do-release-upgrade -f DistUpgradeViewNonInteractive
fi

sudo apt update && sudo apt upgrade -y
sudo apt install -y ubuntu-desktop-minimal
sudo apt remove --autoremove gnome-initial-setup

# Setup security updates automatic

# Install/configure hardware specific dependencies

# Setup pos user
if ! id -u "pos" >/dev/null 2>&1; then
  sudo useradd pos
  echo "pos:pos" | sudo chpasswd
  sudo sed -i 's/#  AutomaticLoginEnable = true/AutomaticLoginEnable=true/g' /etc/gdm3/custom.conf
  sudo sed -i 's/#  AutomaticLogin = user1/AutomaticLogin=pos/g' /etc/gdm3/custom.conf
fi

# SSH only for quikserve user with key

# Install POS

# Remove autologin for setup
sudo rm /etc/systemd/system/getty@tty1.service.d/override.conf

sudo reboot