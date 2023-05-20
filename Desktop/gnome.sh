#!/bin/bash
apt-get update
apt install gnome-shell gnome-shell-extension-ubuntu-dock gnome-shell-extensions gnome-terminal -y
apt install yaru-theme-gtk yaru-theme-icon gnome-tweaks dbus-x11 -y
mkdir /root/.vnc
echo "
#!/bin/bash
export XDG_CURRENT_DESKTOP="GNOME"
service dbus start
gnome-shell --x11 " >> /root/.vnc/xstartup
echo "vncserver " >> /usr/local/bin/vncstart
echo "vncserver -kill :* ; rm -rf /tmp/.X1-lock ; rm -rf /tmp/.X11-unix/X1" >> /usr/local/bin/vncstop
chmod +x /root/.vnc/xstartup
chmod +x /usr/local/bin/vncstart 
chmod +x /usr/local/bin/vncstop 
sleep 2
echo "deb http://ftp.debian.org/debian stable main contrib non-free" >> /etc/apt/sources.list
apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv-keys 648ACFD622F3D138
apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv-keys 0E98404D386FA1D9
apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv-keys 605C66F00D6C9793
apt update
apt install firefox-esr -y 
clear 
echo "Please enter your vnc password"
vncstart 
sleep 4
DISPLAY=:1 firefox &
sleep 10
pkill -f firefox
vncstop
sleep 4
wget -O $(find /root/.mozilla/firefox -name *.default-esr)/user.js https://raw.githubusercontent.com/23xvx/Termux-Ubuntu-Installer/main/Configures/user.js
rm -rf xfce.sh 

