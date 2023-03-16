#!/bin/bash

# This script is used to configure the system after the user has logged in.
# It can be run everytime.

gsettings set org.gnome.desktop.session idle-delay 0
gsettings set org.gnome.desktop.interface color-scheme prefer-dark

# TODO could determine if a) there is a second monitor and b) its port and c) where to put it
xrandr --output DP-1 --pos 0x1080

x0vncserver --passwordfile ~/.vnc/passwd -display: 0 --localhost no