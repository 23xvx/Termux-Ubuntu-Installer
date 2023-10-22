#!/bin/bash
sudo apt-get update 
sudo apt-get install xfce4 xfce4-terminal dbus-x11 tigervnc-standalone-server xfce4-appmenu-plugin -y
sudo apt-get install yaru-theme-gtk yaru-theme-icon ubuntu-wallpapers ubuntu-wallpapers-jammy -y 
echo "service dbus start ; vncserver -xstartup /usr/bin/startxfce4" >> /usr/local/bin/vncstart
echo "vncserver -kill :* ; rm -rf /tmp/.X1-lock ; rm -rf /tmp/.X11-unix/X1" >> /usr/local/bin/vncstop
chmod +x /usr/local/bin/vncstart 
chmod +x /usr/local/bin/vncstop 
sleep 2
clear 
echo "Please enter your vnc password"
vncstart
sleep 5 
vncstop 
sleep 4
vncstart
sleep 4
dbus-launch xfconf-query -c xsettings -p /Net/ThemeName -s "Yaru-dark"
sleep 4
dbus-launch xfconf-query -c xfwm4 -p /general/theme -s "Yaru-dark"
sleep 4
dbus-launch xfconf-query -c xsettings -p /Net/IconThemeName -s  "Yaru-dark"
sleep 4
dbus-launch xfconf-query -c xsettings -p /Gtk/CursorThemeName -s "Yaru-dark"
sleep 4
dbus-launch xfconf-query -c xfce4-desktop -p $(dbus-launch xfconf-query -c xfce4-desktop -l | grep last-image) -s /usr/share/backgrounds/warty-final-ubuntu.png
sleep 5
vncstop
sleep 2

