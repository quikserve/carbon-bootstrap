#!/bin/bash

echo "QuikServe Solutions"
echo "Setup will now begin..."

# Detect hardware

# Install base dependencies
sudo apt update && sudo apt upgrade -y
sudo apt install -y ubuntu-desktop-minimal

# Setup security updates automatic

# Install/configure hardware specific dependencies

# Setup pos user
sudo useradd pos
echo "pos:pos" | sudo chpasswd
sudo usermod -a -G nopasswdlogin pos
echo "auth sufficient pam_succeed_if.so user ingroup nopasswdlogin" | sudo tee -a /etc/pam.d/gdm-password

# SSH only for quikserve user with key

# Install POS

 # Remove autologin for setup
#sudo rm /etc/systemd/system/getty@tty1.service.d/override.conf