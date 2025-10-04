#!/bin/sh 
R="$(printf '\033[1;31m')"
G="$(printf '\033[1;32m')"
Y="$(printf '\033[1;33m')"
W="$(printf '\033[1;37m')"
C="$(printf '\033[1;36m')"

Git_Cloning(){
clear 
echo ${G}"Installing requirements....."${W}
sudo apt install git wget rofi plank gtk2-engines-murrine unzip dconf-cli xfce4-panel-profiles sassc libxml2-utils libglib2.0-dev-bin bzip2 -y 
sudo apt install pulseaudio -y
clear  
echo ${G}"Cloning repositories....."${W}
cd 
git clone https://github.com/vinceliuice/WhiteSur-gtk-theme
git clone https://github.com/vinceliuice/WhiteSur-icon-theme 
git clone https://github.com/vinceliuice/WhiteSur-cursors
git clone https://github.com/vinceliuice/WhiteSur-wallpapers
git clone https://github.com/adi1090x/rofi
sleep 1
clear 
}

Installing_Theme(){
echo ${G}"Installing gtk theme ..."
cd ~/WhiteSur-gtk-theme ; ./install.sh ; cd ; clear
echo ${G}"Installing icon theme ..."${W}
cd ~/WhiteSur-icon-theme ; ./install.sh ; cd ; clear 
echo ${G}"Installing cursor theme ..."${W}
cd ~/WhiteSur-cursors ; ./install.sh ; cd ; clear
echo ${G}"Installing background ..."${W}
cd ~/WhiteSur-wallpapers ; ./install-wallpapers.sh ; cd ; clear 
echo ${G}"Installing rofi theme ...."${W}
cd ~/rofi ; ./setup.sh ; cd ; clear  
cp ~/.local/share/backgrounds/* /usr/share/backgrounds/
[[ ! -d "/usr/share/icons/WhiteSur-cursors" ]] && {
    cp -r ~/.local/share/icons/WhiteSur-cursors /usr/share/icons/
} 
}

Applying_Theme(){
echo ${G}"Applying themes, please wait....."${W}
sleep 2 
dbus-launch xfconf-query -c xfce4-desktop -np '/desktop-icons/style' -t 'int' -s '0'
sleep 2
dbus-launch xfconf-query -c xsettings -p /Net/ThemeName -s "WhiteSur-Dark"
sleep 2
dbus-launch xfconf-query -c xfwm4 -p /general/theme -s "WhiteSur-Dark"
sleep 2
dbus-launch xfconf-query -c xsettings -p /Net/IconThemeName -s  "WhiteSur-dark"
sleep 2
dbus-launch xfconf-query -c xsettings -p /Gtk/CursorThemeName -s "WhiteSur-cursors"
sleep 10
dbus-launch xfconf-query -c xfwm4 -p /general/show_dock_shadow -s false
sleep 2
rm -rf .config/rofi/config.rasi
sleep 1
vncstart # Apply icons and background when vncserver has started
sleep 2
dbus-launch xfconf-query -c xsettings -p /Net/IconThemeName -s  "WhiteSur-dark"
sleep 2
dbus-launch xfconf-query -t string -c xfce4-desktop -np /backdrop/screen0/monitorVNC-0/workspace0/last-image -s $HOME/.local/share/backgrounds/WhiteSur-light.jpg
sleep 10
vncstop 
mkdir -p ~/.local/share/xfce4-panel-profiles/
mkdir -p ~/.config/autostart
mkdir -p ~/.local/share/plank/themes
mkdir -p ~/.config/plank/dock1/
cp -r ~/WhiteSur-gtk-theme/src/other/plank/theme-* ~/.local/share/plank/themes
}

Applying_Plank(){
clear 
echo ${G}"Downloading requried file..."${W}
cd
wget https://github.com/23xvx/Termux-Ubuntu-Installer/raw/main/Themes/macos.zip
unzip macos.zip 
rm -rf macos.zip 
cp  ~/macos/xpple_menu/applications/launchpad.desktop /usr/share/applications/
mv ~/macos/plank/launchers ~/.config/plank/dock1/
mv ~/macos/xpple_menu/applications ~/.local/share/
mv ~/macos/plank/plank.desktop ~/.config/autostart
[[ ! -d "$HOME/.local/share/icons" ]] && {
    mkdir $HOME/.local/share/icons
    cp -r /usr/share/icons/WhiteSur $HOME/.local/share/icons/
}
cp ~/macos/plank/rofi/launchpad.svg ~/.local/share/icons/WhiteSur/ 
mv ~/macos/plank/rofi/style-1.rasi ~/.config/rofi/launchers/type-3/style-1.rasi
mv ~/macos/plank/rofi/launcher.sh ~/.config/rofi/launchers/type-3/launcher.sh
chmod +x ~/.config/rofi/launchers/type-3/launcher.sh
vncstart 
clear 
sleep 5
cat ~/macos/plank/dock.ini | dbus-launch dconf load  /net/launchpad/plank/docks/dock1/
sleep 3 
vncstop 
}

Applying_Panel(){
mkdir -p /usr/share/menus
mv ~/macos/xpple_menu/xpple.menu /usr/share/menus/
dbus-launch xfconf-query -c xfwm4 -p /general/button_layout -s "CHM|"
mv ~/macos/panel/config.txt $HOME/
tar --sort=name --format ustar -cvjhf ubuntu.tar.bz2 config.txt
dbus-launch xfce4-panel-profiles load ubuntu.tar.bz2 
sleep 2
vncstop
# FIX appmenu plugin
cat > ~/.config/gtk-3.0/gtk.css <<- EOF
/* appmenu workaround fix */
.-vala-panel-appmenu-core > * {
    min-width: 1500px;
}
EOF
clear 
}

Remove_File(){
cd 
rm -rf macos WhiteSur* rofi config.txt ubuntu.tar.bz2 
clear 
}


Git_Cloning
Installing_Theme
Applying_Theme
Applying_Plank
Applying_Panel
Remove_File