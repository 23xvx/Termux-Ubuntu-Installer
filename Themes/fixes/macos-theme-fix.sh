#!/usr/bin/bash

# Some workaround fixes in case the theme hasn't applied fully

### FIX appmenu plugin
cat > ~/.config/gtk-3.0/gtk.css <<- EOF
/* appmenu workaround fix */
.-vala-panel-appmenu-core > * {
    min-width: 1500px;
}
EOF

### FIX plank theme not being applied
curl https://raw.githubusercontent.com/23xvx/Termux-Ubuntu-Installer/refs/heads/main/Themes/macos/plank/dock.ini | | dbus-launch dconf load  /net/launchpad/plank/docks/dock1/

### FIX wallpaper hasn't being changed/no wallpaper
dbus-launch xfconf-query -t string -c xfce4-desktop -np /backdrop/screen0/monitorVNC-0/workspace0/last-image -s $HOME/.local/share/backgrounds/WhiteSur-light.jpg

### FIX launchpad (rofi) can't startup normally
rm -rf ~/.config/rofi/launchers/type-3/launcher.sh
wget https://raw.githubusercontent.com/23xvx/Termux-Ubuntu-Installer/refs/heads/main/Themes/macos/plank/rofi/launcher.sh -P ~/.config/rofi/launchers/type-3
chmod +x ~/.config/rofi/launchers/type-3/launcher.sh