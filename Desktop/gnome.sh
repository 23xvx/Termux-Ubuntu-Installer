#!/bin/bash
apt-get update
clear
echo "This would install xfce first in order to get a desktop base "
sudo apt install xfce4 dbus-x11 dbus -y --no-install-recommends
sleep 1
sudo apt install tigervnc-standalone-server -y
sleep 1
clear  
echo "Please enter your vnc password"
vncserver 
sleep 4
vncserver -kill :1
sleep 2 
sudo apt remove xfce4 -y 
sleep 1 
sudo apt install gnome-shell gnome-shell-extension-ubuntu-dock gnome-shell-extensions gnome-terminal -y
sudo apt install yaru-theme-gtk yaru-theme-icon gnome-tweaks dbus-x11 -y
sudo apt autoremove -y 
echo "
#!/bin/bash
export XDG_CURRENT_DESKTOP="GNOME"
service dbus start
gnome-shell --x11 " >> $HOME/.vnc/xstartup
echo "vncserver " >> /usr/local/bin/vncstart
echo "vncserver -kill :* ; rm -rf /tmp/.X1-lock ; rm -rf /tmp/.X11-unix/X1" >> /usr/local/bin/vncstop
chmod +x $HOME/.vnc/xstartup
chmod +x /usr/local/bin/vncstart 
chmod +x /usr/local/bin/vncstop 
sleep 2
vncstart 
sleep 2 
dbus-launch gsettings set org.gnome.desktop.interface gtk-theme "Yaru-dark"
sleep 2
dbus-launch gsettings set org.gnome.desktop.interface icon-theme "Yaru-dark"
sleep 2
rm -rf gnome.sh 

