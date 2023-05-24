#!/bin/bash
sudo apt-get update 
sudo apt-get install mate-desktop-environment mate-terminal mate-tweak -y
sudo apt-get install yaru-theme-gtk yaru-theme-icon ubuntu-wallpapers dconf-cli -y 
echo "vncserver -xstartup /usr/bin/mate-session" >> /usr/local/bin/vncstart
echo "vncserver -kill :* ; rm -rf /tmp/.X1-lock ; rm -rf /tmp/.X11-unix/X1" >> /usr/local/bin/vncstop
chmod +x /usr/local/bin/vncstart 
chmod +x /usr/local/bin/vncstop 
sleep 2
echo "Please enter your vnc password"
vncstart
sleep 4
vncstop 
sleep 2
vncstart 
sleep 4
dbus-launch dconf write /org/mate/desktop/interface/gtk-theme "'Yaru-MATE-dark'"
sleep 2
dbus-launch dconf write /org/mate/marco/general/theme "'Yaru-MATE-dark'"
sleep 2
dbus-launch dconf write /org/mate/desktop/interface/icon-theme "'Yaru-MATE-dark'"
sleep 2
dbus-launch dconf write /org/mate/desktop/peripherals/mouse/cursor-theme "'Yaru-MATE-dark'"
vncstop 
rm -rf mate.sh 