#!/bin/sh
sudo apt-get update 
sudo apt install budgie-desktop -y
sudo apt install dbus-x11 tigervnc-standalone-server thunar adwaita-icon-theme-full -y  
service dbus start 
echo "service dbus start ; vncserver -xstartup /usr/bin/budgie-desktop " >> /usr/local/bin/vncstart
echo "vncserver -kill :* ; rm -rf /tmp/.X1-lock ; rm -rf /tmp/.X11-unix/X1" >> /usr/local/bin/vncstop
chmod +x /usr/local/bin/vncstart 
chmod +x /usr/local/bin/vncstop 
sleep 2
clear 
echo "Please enter your vnc password"
vncstart
sleep 10 
vncstop 
clear 
echo "Installing themes ..."
sleep 2 
sudo apt install ubuntu-budgie-themes gnome-terminal -y 
sleep 5 
dbus-launch gsettings set org.gnome.desktop.interface icon-theme 'Humanity-Dark'
sleep 2
dbus-launch gsettings set org.gnome.desktop.interface gtk-theme 'Pocillo-dark'
sleep 2
dbus-launch gsettings set org.gnome.desktop.interface cursor-theme 'Adwaita'
sleep 2 
dbus-launch gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 
sleep 2 
vncstop 