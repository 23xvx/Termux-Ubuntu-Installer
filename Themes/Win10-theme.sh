#!/bin/sh 

G="$(printf '\033[1;32m')"
W="$(printf '\033[1;37m')"

echo ${G}"Installing Requriements..."${W}
sudo apt install dbus-x11 git wget zip gettext plasma-widgets-addons jq curl gwenview -y

# Clone Themes
git clone https://github.com/yeyushengfan258/We10X-icon-theme.git
git clone https://github.com/yeyushengfan258/We10XOS-kde.git
git clone https://github.com/B00merang-Project/Windows-10.git
git clone https://github.com/Zren/plasma-applet-presentwindows.git

# Download win8.1 cursor, menu X and menu Z 
# Thanks for solution from https://unix.stackexchange.com/questions/743891/download-files-from-gnome-look-org-via-cli
curl -Lfs https://store.kde.org/p/1367178/loadFiles | jq -r '.files | first.version as $v | .[] | select(.version == "0.3").url' | perl -pe 's/\%(\w\w)/chr hex $1/ge' | xargs wget -q --show-progress
curl -Lfs https://store.kde.org/p/1367167/loadFiles | jq -r '.files | first.version as $v | .[] | select(.version == "0.3").url' | perl -pe 's/\%(\w\w)/chr hex $1/ge' | xargs wget -q --show-progress
curl -Lfs https://www.gnome-look.org/p/1084938/loadFiles | jq -r '.files | first.version as $v | .[] | select(.version == "R2").url' | perl -pe 's/\%(\w\w)/chr hex $1/ge' | xargs wget -q --show-progress

# Install Themes
echo ${G}"Installing Themes..."${W}
mkdir -p ~/.themes
cd We10X-icon-theme ;./install.sh ;cd
cd We10XOS-kde ;./install.sh ;cd
mv Windows-10 ~/.themes/Windows-10
cd plasma-applet-presentwindows ;bash build ;bash install ;cd
tar xpf 'Win-8.1-NS-S-(KDE).R2.tar.bz2'
cd 'Win-8.1-NS-S-(KDE)' ;sudo cp -rf Win-8.1-NS/ /usr/share/icons/Win-8.1-NS 
sudo update-alternatives --install /usr/share/icons/default/index.theme x-cursor-theme /usr/share/icons/Win-8.1-NS/cursor.theme 25 ;cd
plasmapkg2 --install menuZ.tar.gz
plasmapkg2 --install menuX.tar.gz

# Apply Themes
vncstart
export DISPLAY=:1 
export XDG_RUNTIME_DIR=/tmp/runtime-user/ #temporary
dbus-launch plasma-apply-desktoptheme We10XOS-dark 
dbus-launch plasma-apply-lookandfeel -a com.github.yeyushengfan258.We10XOS-dark 
dbus-launch plasma-apply-colorscheme We10XOSDark 
dbus-launch plasma-apply-cursortheme Win-8.1-NS
sleep 20
vncstop
sed -i 's/gtk-theme-name="Breeze"/gtk-theme-name="Windows-10"/g' ~/.gtkrc-2.0 
sed -i 's/gtk-theme-name=Breeze/gtk-theme-name=Windows-10/g' ~/.config/gtk-3.0/settings.ini
sed -i 's/gtk-theme-name=Breeze/gtk-theme-name=Windows-10/g' ~/.config/gtk-4.0/settings.ini

# Panel Configuration
rm -rf ~/.config/plasma-org.kde.plasma.desktop-appletsrc
wget -q https://raw.githubusercontent.com/23xvx/Termux-Ubuntu-Installer/main/Themes/win10/plasma-org.kde.plasma.desktop-appletsrc -P ~/.config/

# Konsole Configuration
mkdir -p ~/.local/share/konsole
cat <<-  EOF > ~/.config/konsolerc
[Desktop Entry]
DefaultProfile=Profile 1.profile

[General]
ConfigVersion=1

[MainWindow]
1920x1200 screen: Height=524
1920x1200 screen: Width=911
1920x1200 screen: XPosition=504
1920x1200 screen: YPosition=333
State=AAAA/wAAAAD9AAAAAAAAA0YAAAHMAAAABAAAAAQAAAAIAAAACPwAAAAA
ToolBarsMovable=Disabled
VNC-0=VNC-0

[UiSettings]
ColorScheme=
EOF

cat <<-  EOF > ~/.local/share/konsole/'Profile 1.profile'
[General]
Command=/bin/bash
Name=Profile 1
Parent=FALLBACK/
EOF

# Cleanup
cd 
rm -rf We10X-icon-theme 'Win-8.1-NS-S-(KDE).R2.tar.bz2' 'Win-8.1-NS-S-(KDE)' plasma-applet-presentwindows menuZ.tar.gz menuX.tar.gz We10XOS-kde
