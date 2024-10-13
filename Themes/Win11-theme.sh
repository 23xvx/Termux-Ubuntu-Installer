#!/bin/sh 

G="$(printf '\033[1;32m')"
W="$(printf '\033[1;37m')"

mkdir -p ~/.local/share/gnome-shell/extensions/
mkdir -p /usr/share/pictures

#themes
git clone https://github.com/yeyushengfan258/Win11-icon-theme
cd Win11-icon-theme
./install.sh
cd 
git clone https://github.com/vinceliuice/Fluent-gtk-theme
cd Fluent-gtk-theme
./install.sh
cd 

#extensions
wget -q --show-progress https://github.com/home-sweet-gnome/dash-to-panel/releases/download/v62/dash-to-panel@jderose9.github.com_v62.zip 
gnome-extensions install -f -q dash-to-panel@jderose9.github.com_v62.zip
wget -q --show-progress https://github.com/aunetx/blur-my-shell/releases/download/v67/blur-my-shell@aunetx.shell-extension.zip
gnome-extensions install -f -q blur-my-shell@aunetx.shell-extension.zip
wget -q --show-progress https://extensions.gnome.org/extension-data/arcmenuarcmenu.com.v57.shell-extension.zip
gnome-extensions install -f -q arcmenuarcmenu.com.v57.shell-extension.zip
git clone https://github.com/marcinjakubowski/date-menu-formatter
mv date-menu-formatter .local/share/gnome-shell/extensions/date-menu-formatter@marcinjakubowski.github.com/
wget -q https://raw.githubusercontent.com/23xvx/Termux-Ubuntu-Installer/main/Images/win11.jpg -P /usr/share/pictures/
wget -q https://raw.githubusercontent.com/23xvx/Termux-Ubuntu-Installer/main/Images/win11logo.png -P /usr/share/pictures/

#applying themes 
echo ${G}"Applying Themes...."${W}
dbus-launch gsettings set org.gnome.desktop.interface icon-theme "Win11-dark"
dbus-launch gsettings set org.gnome.desktop.interface gtk-theme "Fluent-Dark"
dbus-launch gnome-extensions disable ubuntu-dock@ubuntu.com
dbus-launch gnome-extensions enable dash-to-panel@jderose9.github.com
dbus-launch gnome-extensions enable arcmenu@arcmenu.com
dbus-launch gnome-extensions enable blur-my-shell@aunetx
dbus-launch gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com
dbus-launch gnome-extensions enable date-menu-formatter@marcinjakubowski.github.com
dbus-launch gsettings set org.gnome.shell.extensions.user-theme name 'Fluent-Dark'
sudo cp ~/.local/share/gnome-shell/extensions/dash-to-panel@jderose9.github.com/schemas/org.gnome.shell.extensions.dash-to-panel.gschema.xml /usr/share/glib-2.0/schemas/ 
sudo cp ~/.local/share/gnome-shell/extensions/blur-my-shell@aunetx/schemas/org.gnome.shell.extensions.blur-my-shell.gschema.xml /usr/share/glib-2.0/schemas/ 
sudo cp ~/.local/share/gnome-shell/extensions/arcmenu@arcmenu.com/schemas/org.gnome.shell.extensions.arcmenu.gschema.xml /usr/share/glib-2.0/schemas/ 
sudo cp ~/.local/share/gnome-shell/extensions/date-menu-formatter@marcinjakubowski.github.com/schemas/org.gnome.shell.extensions.date-menu-formatter.gschema.xml /usr/share/glib-2.0/schemas/ 
sudo glib-compile-schemas /usr/share/glib-2.0/schemas/
dbus-launch gsettings set org.gnome.shell.extensions.dash-to-panel panel-element-positions '{"0":[{"element":"showAppsButton","visible":false,"position":"stackedTL"},{"element":"activitiesButton","visible":false,"position":"stackedTL"},{"element":"leftBox","visible":true,"position":"centerMonitor"},{"element":"taskbar","visible":true,"position":"centerMonitor"},{"element":"centerBox","visible":true,"position":"stackedBR"},{"element":"rightBox","visible":true,"position":"stackedBR"},{"element":"systemMenu","visible":true,"position":"stackedBR"},{"element":"dateMenu","visible":true,"position":"stackedBR"},{"element":"desktopButton","visible":true,"position":"stackedBR"}]}'
dbus-launch gsettings set org.gnome.shell.extensions.dash-to-panel appicon-margin 0
dbus-launch gsettings set org.gnome.shell.extensions.dash-to-panel appicon-padding 6
dbus-launch gsettings set org.gnome.shell.extensions.dash-to-panel tray-size 16
dbus-launch gsettings set org.gnome.shell.extensions.dash-to-panel leftbox-size 16
dbus-launch gsettings set org.gnome.shell.extensions.dash-to-panel status-icon-padding 4
dbus-launch gsettings set org.gnome.shell.extensions.arcmenu menu-layout 'Eleven'
dbus-launch gsettings set org.gnome.shell.extensions.arcmenu menu-height 750
dbus-launch gsettings set org.gnome.shell.extensions.arcmenu left-panel-width 175
dbus-launch gsettings set org.gnome.shell.extensions.arcmenu force-menu-location 'BottomCentered'
dbus-launch gsettings set org.gnome.shell.extensions.arcmenu menu-item-icon-size 'Large'
dbus-launch gsettings set org.gnome.shell.extensions.arcmenu button-padding 5
dbus-launch gsettings set org.gnome.shell.extensions.arcmenu custom-menu-button-icon-size 33.0
dbus-launch gsettings set org.gnome.shell.extensions.arcmenu custom-menu-button-icon '/usr/share/pictures/win11logo.png'
dbus-launch gsettings set org.gnome.shell.extensions.arcmenu menu-button-icon 'Custom_Icon'
dbus-launch gsettings set org.gnome.shell.extensions.blur-my-shell.dash-to-dock override-background false
dbus-launch gsettings set org.gnome.shell.extensions.blur-my-shell.dash-to-dock brightness 1.0
dbus-launch gsettings set org.gnome.shell.extensions.blur-my-shell.dash-to-dock sigma 10
dbus-launch gsettings set org.gnome.shell.extensions.date-menu-formatter pattern 'MM/dd/yy\nHH:mm a'
dbus-launch gsettings set org.gnome.desktop.background picture-uri 'file:///usr/share/pictures/win11.jpg'

#cleanup
rm -rf Win11-icon-theme Fluent-gtk-theme dash-to-panel@jderose9.github.com_v62.zip arcmenuarcmenu.com.v57.shell-extension.zip blur-my-shell@aunetx.shell-extension.zip