#!/bin/bash

echo "QuikServe Solutions"
echo "Setup will now begin..."
echo -e "\n\nPlease be patient as this may take a few minutes.\n\n"

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

export NEEDRESTART_MODE=a
export DEBIAN_FRONTEND=noninteractive

# Detect hardware

# Install base dependencies

# Temporary dist upgrade as autoinstaller has issues with 22.04, but thats what we want
# Hopefully 22.04 resolves this issue and we can remove this and install 22.04 directly
# This issue may provide updates: https://bugs.launchpad.net/subiquity/+bug/2000470
version=$(lsb_release -sr)
if [ $version == "20.04" ]; then
  sudo do-release-upgrade -f DistUpgradeViewNonInteractive
fi

sudo apt update && sudo NEEDRESTART_MODE=a DEBIAN_FRONTEND=noninteractive apt upgrade -y
sudo NEEDRESTART_MODE=a DEBIAN_FRONTEND=noninteractive apt install -y ubuntu-desktop-minimal
sudo DEBIAN_FRONTEND=noninteractive apt remove --autoremove gnome-initial-setup

# Setup security updates automatic

# Install/configure hardware specific dependencies

# Setup pos user
if ! id -u "pos" >/dev/null 2>&1; then
  sudo useradd -m pos -s /bin/bash
  echo "quikserve:quikserve" | sudo chpasswd
  sudo sed -i 's/#  AutomaticLoginEnable = true/AutomaticLoginEnable=true/g' /etc/gdm3/custom.conf
  sudo sed -i 's/#  AutomaticLogin = user1/AutomaticLogin=pos/g' /etc/gdm3/custom.conf
fi

sudo -u pos dbus-launch --exit-with-session gsettings set org.gnome.desktop.session idle-delay 0
sudo -u pos dbus-launch --exit-with-session gsettings set org.gnome.desktop.interface color-scheme prefer-dark

# Install POS
wget 
wget -O carbon.sh https://raw.githubusercontent.com/quikserve/carbon-bootstrap/master/carbon/install.sh
chmod +x carbon.sh
./carbon.sh

sudo mkdir -p /home/pos/.config/autostart
echo "[Desktop Entry]
Type=Application
Exec=/home/pos/quikserve/pos
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name[en_US]=POS
Name=POS
Comment[en_US]=
Comment=" | sudo tee /home/pos/.config/autostart/pos.desktop
sudo chown -R pos:pos /home/pos/.config

# Remove autologin for setup
sudo rm /etc/systemd/system/getty@tty1.service.d/override.conf

sudo reboot