#!/bin/sh
sudo apt-get update 
sudo apt install ubuntucinnamon-desktop --no-install-recommends -y
sudo apt install dbus-x11 tigervnc-standalone-server thunar -y 
mkdir -p ~/.vnc 
mkdir -p /run/dbus/
echo "#!/bin/bash
service dbus start
dbus-launch cinnamon-session " >> $HOME/.vnc/xstartup
echo "vncserver " >> /usr/local/bin/vncstart
echo "vncserver -kill :* ; rm -rf /tmp/.X1-lock ; rm -rf /tmp/.X11-unix/X1" >> /usr/local/bin/vncstop
chmod +x /usr/local/bin/vncstart 
chmod +x /usr/local/bin/vncstop 
chmod +x ~/.vnc/xstartup 
sleep 2
clear 
echo "Please enter your vnc password"
vncstart
sleep 5 
vncstop 