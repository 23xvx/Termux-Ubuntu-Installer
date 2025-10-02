#!/bin/bash
sudo apt update 
sudo apt-mark hold elementary-xfce-icon-theme  # cause problems during installation
sudo apt install xfce4 xfce4-terminal dbus-x11 tigervnc-standalone-server xfce4-appmenu-plugin -y
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
