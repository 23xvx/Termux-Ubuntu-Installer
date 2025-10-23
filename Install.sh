#!/data/data/com.termux/files/usr/bin/bash

PD=$PREFIX/var/lib/proot-distro/installed-rootfs
ds_name=ubuntu-lts

clear

# Colours
R="$(printf '\033[1;31m')"
G="$(printf '\033[1;32m')"
Y="$(printf '\033[1;33m')"
W="$(printf '\033[1;37m')"
C="$(printf '\033[1;36m')"

## ask() - prompt the user with a message and wait for a Y/N answer
## copied from udroid 
ask() {
    local msg=$*

    echo -ne "$msg\t[y/n]: "
    read -r choice

    case $choice in
        y|Y|yes) return 0;;
        n|N|No) return 1;;
        "") return 0;;
        *) return 1;;
    esac
}

## download_script() - download a script online
download_script() {
    local url=$1
    local dir=$2
    local mode=$3
    
    script=$(echo $url | awk -F / '{print $NF}')

    case $mode in
        verbose) WGET="wget --show-progress" ;;
        silence) WGET="wget -q --show-progress" ;;
        *) WGET="wget" ;;
    esac

    $WGET $url -P $dir
}

# Install proot-distro
requirements() {
    echo ${G}"This is a script to install ubuntu in proot-distro"
    sleep 1 
    echo ${G}"Installing required packages..."${W}
    pkg install pulseaudio proot-distro wget  -y
    [[ ! -d "$HOME/storage" ]] && {
        echo ${C}"Please allow storage permission"${W}
        termux-setup-storage
    }
    [[ ! -d "$PREFIX/var/lib/proot-distro" ]] && {
        mkdir -p $PREFIX/var/lib/proot-distro
        mkdir -p $PREFIX/var/lib/proot-distro/installed-rootfs
    }
    echo


    # Download scripts for ubuntu noble (if not existed)
    if [[ ! -f "$PREFIX/etc/proot-distro/$ds_name.sh" ]]; then
        download_script "https://raw.githubusercontent.com/23xvx/Termux-Ubuntu-Installer/main/ubuntu-lts.sh" "$PREFIX/etc/proot-distro/" silence
    fi

    [[ -d "$PD/$ds_name" ]] && {
        if ask ${Y}"Existing ubuntu found, remove it?"${W}; then
            echo ""
            echo ${Y}"Deleting existing directory...."${W}
            proot-distro remove ubuntu-lts || ( echo ${R}"Cannot remove existing directory.." && exit 1 )
        else
            echo ${R}"Sorry, but we cannot complete the installation"
            exit 1
        fi
    }
}

# Pick desktop
choose_desktop() {
    clear
    echo ${C}"Please choose your desktop"${Y}
    echo " 1) XFCE (Light Weight)"
    echo " 2) GNOME (Default desktop of ubuntu) "
    echo " 3) MATE "
    echo " 4) Windows 10 (KDE with custom themes)"
    echo " 5) Windows 11 (GNOME with custom themes)"
    echo " 6) MacOS (XFCE with custom themes)"
    echo " 7) Cinnamon "
    echo ${C}"Please enter number 1-7 to choose your desktop "
    echo ${C}"If you don't want a desktop please just enter '${W}CLI${C}'"${W}
    read desktop
    sleep 1
    case $desktop in
        1|3|4|6|7) echo ${G}"Lets start the installation"${Y} ;;
        2|5) echo ${Y}"Gnome is no longer supported..."${Y} ; sleep 2 ; choose_desktop;;
        CLI) echo ${G}"Install raw ubuntu..."${Y} ;;
        *) echo ${R}"Invalid answer"; sleep 1 ; choose_desktop ;;
    esac
}

# Install and Setup ubuntu 
configures() {
    proot-distro install ubuntu-lts
    echo ${G}"Installing requirements in ubuntu..."${W}
    cat > $PD/$ds_name/root/.bashrc <<- EOF
    apt-get update
    apt-get upgrade -y
    apt install sudo nano wget openssl git -y
    exit
    echo
EOF
    proot-distro login ubuntu-lts
    rm -rf $PD/$ds_name/root/.bashrc
}

# Ask if setup a user
user() {
    clear
    if ask ${C}"Do you want to add a user"${W}; then
        echo ""
        echo ${C}"Please enter a username : "${W}
        read username
        directory=$PD/$ds_name/home/$username
        login="proot-distro login ubuntu-lts --user $username"
        echo ""
        sleep 1
        echo ${G}"Adding a user ...."
        cat > $PD/$ds_name/root/.bashrc <<- EOF
        useradd -m \
            -G sudo \
            -d /home/${username} \
            -k /etc/skel \
            -s /bin/bash \
            $username
        echo $username ALL=\(root\) ALL > /etc/sudoers.d/$username
        chmod 0440 /etc/sudoers.d/$username
        echo "$username ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
        exit
        echo
EOF
        proot-distro login ubuntu-lts
        rm -rf $PD/$ds_name/root/.bashrc
        sleep 2
        [[ ! -d $directory ]] && {
            echo -e ${R}"Failed to add user\nKeep installation as root"
            directory=$PD/$ds_name/root
            login="proot-distro login ubuntu-lts"
        }
        clear 
    else
        echo ""
        echo ${G}"The installation will be completed as root"
        sleep 2
        clear
        directory=$PD/$ds_name/root
        login="proot-distro login ubuntu-lts"
    fi 
}

# install specific desktop
install_desktop() {
    desk=true
    case $desktop in
        1) xfce_mode ;;
        2) gnome_mode ;;
        3) mate_mode ;;
        4) kde_mode ; win10_theme ;;
        5) gnome_mode ; win11_theme ;;
        6) xfce_mode ; macos_theme ;;
        7) cinnamon_mode ;;
        *) echo ${G}"No desktop selected , skipping ...." ; desk=false ; sleep 2 ;;
    esac
    
    # if desktop is installed, also install external apps
    if $desk ; then 
        apps
    fi
}

# Different mode to download different scripts
xfce_mode() {
    echo ${G}"Installing XFCE Desktop..."${W}
    download_script "https://raw.githubusercontent.com/23xvx/Termux-Ubuntu-Installer/main/Desktop/xfce.sh" $directory silence
    $login -- /bin/bash xfce.sh
    rm -rf $directory/xfce.sh
}

gnome_mode() {
    echo ${G}"Installing GNOME Desktop...."${W}
    download_script "https://raw.githubusercontent.com/23xvx/Termux-Ubuntu-Installer/main/Desktop/gnome.sh" $directory silence
    $login -- /bin/bash gnome.sh 
    rm -rf $directory/gnome.sh
}

mate_mode() {
    echo ${G}"Installing Mate Desktop..."${W}
    download_script "https://raw.githubusercontent.com/23xvx/Termux-Ubuntu-Installer/main/Desktop/mate.sh" $directory silence
    $login -- /bin/bash mate.sh
    rm -rf $directory/mate.sh
}

kde_mode() {
    echo ${G}"Installing KDE Desktop..."${W}
    download_script "https://raw.githubusercontent.com/23xvx/Termux-Ubuntu-Installer/main/Desktop/kde.sh" $directory silence
    $login -- /bin/bash kde.sh
    rm -rf $directory/kde.sh
}

cinnamon_mode() {
    echo ${G}"Installing Cinnamon Desktop..."${W}
    download_script "https://raw.githubusercontent.com/23xvx/Termux-Ubuntu-Installer/main/Desktop/cinnamon.sh" $directory silence
    $login -- /bin/bash cinnamon.sh
    rm -rf $directory/cinnamon.sh
}

win10_theme() {
    download_script "https://raw.githubusercontent.com/23xvx/Termux-Ubuntu-Installer/main/Themes/Win10-theme.sh" $directory silence
    $login -- /bin/bash Win10-theme.sh
    rm -rf $directory/Win10-theme.sh
}

win11_theme() {
    download_script "https://raw.githubusercontent.com/23xvx/Termux-Ubuntu-Installer/main/Themes/Win11-theme.sh" $directory silence
    $login -- /bin/bash Win11-theme.sh
    rm -rf $directory/Win11-theme.sh
}

macos_theme() {
    download_script "https://raw.githubusercontent.com/23xvx/Termux-Ubuntu-Installer/main/Themes/MacOS-theme.sh" $directory silence
    $login -- /bin/bash MacOS-theme.sh
    rm -rf $directory/MacOS-theme.sh
}

# Install external apps
apps() {
    clear

    # Install firefox
    if ask ${C}"Install Firefox Web Broswer?"${W}; then
        echo -e ${G}"\nInstalling Firefox Broswer ...." ${W}
        download_script "https://raw.githubusercontent.com/23xvx/Termux-Ubuntu-Installer/main/Apps/firefox.sh" $directory silence
        [[ -f $directory/.bashrc ]] && mv $directory/.bashrc $directory/.bak
        cat > $directory/.bashrc <<- EOF
        bash firefox.sh 
        clear 
        vncstart 
        sleep 4
        DISPLAY=:1 firefox-esr &
        sleep 10
        pkill -f firefox-esr
        vncstop
        sleep 2
        exit 
        echo 
EOF
        $login 
        echo 'user_pref("sandbox.cubeb", false);
        user_pref("security.sandbox.content.level", 1);' >> $directory/.mozilla/firefox-esr/*default-esr*/prefs.js
        rm -rf $directory/.bashrc
        mv $directory/.bak $directory/.bashrc
        clear
        sleep 1
    else 
        echo -e ${G}"\nNot installing , skip process..\n"${W}
        sleep 1
    fi

    # Install discord(webcord)
    if ask ${C}"Install Discord (Webcord)?"${W}; then
        echo -e ${G}"\nInstalling Discord ...." ${W}
        download_script "https://raw.githubusercontent.com/23xvx/Termux-Ubuntu-Installer/main/Apps/webcord.sh" $directory silence
        $login -- /bin/bash webcord.sh
        rm $directory/webcord.sh
        clear
    else 
        echo -e ${G}"\nNot installing , skip process..\n" ${W}
        sleep 1
    fi

    # Install VScode
    if ask ${C}"Install VScode?"${W}; then
        echo -e ${G}"\nInstalling Vscode ...." ${W}
        download_script "https://raw.githubusercontent.com/23xvx/Termux-Ubuntu-Installer/main/Apps/vscodefix.sh" $directory silence
        $login -- /bin/bash vscodefix.sh
        rm $directory/vscodefix.sh
    else 
        echo -e ${G}"\nNot installing , skip process..\n" ${W}
        sleep 1
    fi
    clear 
}

# Write startup scripts
fixes() {
    [[ -f $PREFIX/bin/start-ubuntu ]] && rm $PREFIX/bin/start-ubuntu
    echo "pulseaudio \
        --start --load='module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1'  \
        --exit-idle-time=-1" >> $PREFIX/bin/start-ubuntu 
    if [[ -z $username ]]; then
        echo "proot-distro login ubuntu-lts --shared-tmp" >> $PREFIX/bin/start-ubuntu 
    else
        echo "proot-distro login ubuntu-lts --shared-tmp --user $username" >> $PREFIX/bin/start-ubuntu
    fi
    chmod +x $PREFIX/bin/start-ubuntu
    [[ ! -f "$directory/.bashrc " ]] && {
        cp $directory/etc/skel/.bashrc $directory
    }
    echo "export PULSE_SERVER=127.0.0.1" >> $directory/.bashrc
}

# End
finish () {
    clear
    sleep 2
    echo ${G}"Installation Complete"
    echo ""
    echo " start-ubuntu      To Start Ubuntu  "
    echo ""
    [[ $desk == "true" ]] && {
    echo " vncstart          To start vncserver (In Ubuntu)"
    echo ""
    echo " vncstop           To stop vncserver (In Ubuntu)"
    echo ""     
    }
    echo ${Y}"Notice : You cannot install it by proot-distro after removing it."
}

# Main program
main () {
    requirements
    choose_desktop
    configures
    user
    install_desktop
    fixes
    finish
}

# call main program
main

