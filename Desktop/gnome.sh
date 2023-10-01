#!/bin/sh
sudo apt-get update
sudo apt install gnome-shell gnome-shell-extension-ubuntu-dock gnome-shell-extensions gnome-terminal gnome-session -y
sudo apt install yaru-theme-gtk yaru-theme-icon gnome-tweaks dbus-x11 nautilus tigervnc-standalone-server -y
clear 
echo "Please enter your vnc password"
vncserver -xstartup /usr/bin/gnome-session 
sleep 4
vncserver -kill :1
sleep 2 
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
dbus-launch gsettings set org.gnome.desktop.interface cursor-theme "Yaru"
sleep 2
dbus-launch gsettings set org.gnome.desktop.background picture-uri 'file:///usr/share/backgrounds/warty-final-ubuntu.png'
sleep 2
dbus-launch gnome-extensions enable ubuntu-dock@ubuntu.com
sleep 2
dbus-launch gsettings set org.gnome.shell.extensions.dash-to-dock dock-position LEFT
sleep 2
dbus-launch gsettings set org.gnome.shell.extensions.dash-to-dock extend-height true
sleep 2
vncstop 

