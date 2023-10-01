#!/data/data/com.termux/files/usr/bin/bash

PD=$PREFIX/var/lib/proot-distro/installed-rootfs
ds_name=ubuntu

#Adding colors
R="$(printf '\033[1;31m')"
G="$(printf '\033[1;32m')"
Y="$(printf '\033[1;33m')"
W="$(printf '\033[1;37m')"
C="$(printf '\033[1;36m')"

requirements() {
    clear 
    echo ${G}"This is a script to install ubuntu 23.04 (Lunar) in proot-distro"
    sleep 1 
    echo ${G}"Installing required packages..."${W}
    pkg install pulseaudio proot-distro wget  -y
    if [ ! -d '/data/data/com.termux/files/home/storage' ]; then
        echo ${C}"Please allow storage permission"${W}
        termux-setup-storage
    fi
    if [[ ! -d "$PREFIX/var/lib/proot-distro" ]]; then
        mkdir -p $PREFIX/var/lib/proot-distro
        mkdir -p $PREFIX/var/lib/proot-distro/installed-rootfs
    fi
    echo
    if [[ -d "$PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu" ]]; then
        echo ${C}"Existing file found, are you sure to remove it? (y or n)"${W}
        read ans
        if [[ "$ans" =~ ^([yY])$ ]]; then
            echo ""
            echo ${W}"Deleting existing directory...."${W}
            proot-distro remove ubuntu
            if [[ -d "$PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu" ]]; then
                echo ${R}"Cannot remove existing file, exiting...."
                echo ${R}"Maybe try to clear Termux Data"
                exit 1
            fi
        mkdir -p $PD/ubuntu
        clear
        elif [[ "$ans" =~ ^([nN])$ ]]; then
            echo ${R}"Sorry, but we cannot complete the installation"
            exit 1
        else
            echo ${R}"Sorry, we cannot identify your answer "
            exit 1
        fi
    fi
}

choose_desktop() {
    clear
    echo ${C}"Please choose your desktop"${Y}
    echo " 1) XFCE (Light Weight)"
    echo " 2) GNOME (Default desktop of ubuntu) "
    echo " 3) MATE "
    echo " 4) Windows 11 (GNOME with custom themes)"
    echo " 5) MacOS (XFCE with custom themes)"
    echo " 6) Cinnamon "
    echo " 7) Budgie "
    echo ${C}"Please press number 1-7 to choose your desktop "
    echo ${C}"If you don't want a desktop please just enter '${W}CLI${C}'"${W}
    read desktop
    sleep 1
    if [[ "$desktop" =~ ^([1])$ ]]; then
        choice 
    elif [[ "$desktop" =~ ^([2])$ ]]; then
        choice 
    elif [[ "$desktop" =~ ^([3])$ ]]; then
        choice 
    elif [[ "$desktop" =~ ^([4])$ ]]; then
        choice 
    elif [[ "$desktop" =~ ^([5])$ ]]; then
        choice 
    elif [[ "$desktop" =~ ^([6])$ ]]; then
        choice 
    elif [[ "$desktop" =~ ^([7])$ ]]; then
        choice
    elif [[ "$desktop" == "CLI" ]]; then
        echo ${G}"No desktop environment will be installed"
    else 
        echo ${R}"Invalid answer"
        sleep 1 
        choose_desktop
    fi 
}

choice() {
    echo ""
    echo ${G}"Your choice is $desktop"
    echo ${G}"Is that your choice ? (y/n)"${W}
    read choice
    if [[ "$choice" =~ ^([yY])$ ]]; then
        echo ${G}"Let's install the desktop !"
        sleep 1
    else
        echo ${Y}"Please choose the desktop again"
        sleep 1
        choose_desktop
    fi
}



downloader() {
    tarball="lunar.tar.xz"
    if [ ! -f $tarball ]; then
        case `dpkg --print-architecture` in
            aarch64)
                archurl="arm64" ;;
            arm*)
                archurl="armhf" ;;
            x86_64)
                archurl="amd64" ;;
            *)
                echo ${R}"Unsupported architecture"; exit 1 ;;
        esac
        clear
        echo ${G}"Downloading rootfs"${W}
        wget -nv "https://cloud-images.ubuntu.com/releases/23.04/release/ubuntu-23.04-server-cloudimg-${archurl}-root.tar.xz" -O $tarball
        sleep 1
    else
    echo " "
    echo ${G}"Existing file found, skip downloading..."
    sleep 1
    fi
}

decompressing() {
    echo ""
    echo ${G}"Decompressing rootfs"${W}
    mkdir -p $PD/ubuntu
    proot --link2symlink  \
        tar --warning=no-unknown-keyword \
            --delay-directory-restore --preserve-permissions \
            -xpf ~/$tarball -C $PD/$ds_name/ --exclude='dev'||:
    if [ ! -f "$PD/$ds_name/bin/su" ]; then
        echo ${R}"Installation has occur an error"
        echo ${R}"Please execute the script again"
        exit 1
    fi
    echo ""
    echo ${Y}"Delete Downloaded file? (y/n)"${W}
    read del
    if [[ "$del" =~ ^([yY])$ ]]; then
    echo ""
    echo ${y}"Deleting ...."
    rm -rf $tarball
    fi
}

configures() {
    echo "127.0.0.1 localhost " >> $PD/$ds_name/etc/hosts
    rm -rf $PD/$ds_name/etc/resolv.conf
    echo "nameserver 8.8.8.8 " >> $PD/$ds_name/etc/resolv.conf
    echo "touch .hushlogin" >> $PD/$ds_name/root/.bashrc
    echo -e "#!/bin/sh\nexit" > "$PD/$ds_name/usr/bin/groups"
    rm -rf $PD/$ds_name/etc/apt/apt.conf.d/99needrestart
    rm -rf $PD/$ds_name/root/.bashrc
    clear 
    echo ${G}"Installing requirements in ubuntu..."${W}
    cat > $PD/$ds_name/root/.bashrc <<- EOF
    apt-get update
    apt install sudo nano udisks2 wget -nv openssl neofetch git -y
    exit
    echo
EOF
    proot-distro login ubuntu
    rm -rf $PD/$ds_name/root/.bashrc
}

user() {
    clear
    echo ${C}"Do you want to add a user (y/n)"
    echo ${Y}"If you are going to install MATE Desktop, it is strongly reccommended to add a user "
    echo "Because mate-menu crashes in root"
    read user
    if [[ "$user" =~ ^([yY])$ ]]; then
        echo ""
        echo ${C}"Please type in your username "${W}
        read username
        directory=$PD/$ds_name/home/$username
        login="proot-distro login ubuntu --user $username"
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
        proot-distro login ubuntu
        rm -rf $PD/$ds_name/root/.bashrc
        sleep 2
        clear 
    elif [[ "$user" =~ ^([nN])$ ]]; then
        sleep 1
        echo ""
        echo ${G}"The installation will be completed as root"
        sleep 2
        clear
        directory=$PD/$ds_name/root
        login="proot-distro login ubuntu"
    else
        echo ${R}"Cannot identify your answer"
        echo ${R}"Please complete the process again"
        sleep 2
        user
    fi 
}

install_desktop() {
    if [[ "$desktop" =~ ^([1])$ ]]; then
        xfce_mode
    elif [[ "$desktop" =~ ^([2])$ ]]; then
        gnome_mode
    elif [[ "$desktop" =~ ^([3])$ ]]; then
        mate_mode
    elif [[ "$desktop" =~ ^([4])$ ]]; then
        gnome_mode
        windows_theme
    elif [[ "$desktop" =~ ^([5])$ ]]; then
        xfce_mode
        macos_theme
    elif [[ "$desktop" =~ ^([6])$ ]]; then
        cinnamon_mode
    elif [[ "$desktop" =~ ^([7])$ ]]; then
        budgie_mode
    else
        echo ${G}"No desktop selected , skipping ...."
        sleep 2
    fi
}

xfce_mode() {
    desk="true"
    echo ${G}"Installing XFCE Desktop..."${W}
    mv $directory/.bashrc $directory/.bak
    cat > $directory/.bashrc <<- EOF
    wget -nv https://raw.githubusercontent.com/23xvx/Termux-Ubuntu-Installer/main/Desktop/xfce.sh
    bash xfce.sh
    rm ~/xfce.sh
    exit
    echo
EOF
    $login
    rm -rf $directory/.bashrc
}

gnome_mode() {
    desk="true"
    echo ${G}"Installing GNOME Desktop...."${W}
    mv $directory/.bashrc $directory/.bak 
    cat > $directory/.bashrc <<- EOF
    wget -nv https://raw.githubusercontent.com/23xvx/Termux-Ubuntu-Installer/main/Desktop/gnome.sh
    bash gnome.sh 
    rm ~/gnome.sh 
    exit
    echo
EOF
    $login
    rm -rf $directory/.bashrc
}

mate_mode() {
    desk="true"  
    echo ${G}"Installing Mate Desktop..."${W}
    mv $directory/.bashrc $directory/.bak 
    cat > $directory/.bashrc <<- EOF
    wget -nv https://raw.githubusercontent.com/23xvx/Termux-Ubuntu-Installer/main/Desktop/mate.sh 
    bash mate.sh 
    rm ~/mate.sh
    exit
    echo
EOF
    $login
    rm -rf $directory/.bashrc
}

cinnamon_mode() {
    desk="true"
    echo ${G}"Installing Cinnamon Desktop..."${W}
    mv $directory/.bashrc $directory/.bak 
    cat > $directory/.bashrc <<- EOF
    wget -nv https://raw.githubusercontent.com/23xvx/Termux-Ubuntu-Installer/main/Desktop/cinnamon.sh
    bash cinnamon.sh 
    rm ~/cinnamon.sh 
    exit
    echo
EOF
    $login
    rm -rf $directory/.bashrc
}

budgie_mode() {
    desk="true"
    echo ${G}"Installing Budgie Desktop..."${W}
    mv $directory/.bashrc $directory/.bak 
    cat > $directory/.bashrc <<- EOF
    wget -nv https://raw.githubusercontent.com/23xvx/Termux-Ubuntu-Installer/main/Desktop/budgie.sh
    bash budgie.sh 
    rm ~/budgie.sh 
    exit
    echo
EOF
    $login
    rm -rf $directory/.bashrc
}

windows_theme() {
    cat > $directory/.bashrc <<- EOF
    wget -nv https://raw.githubusercontent.com/23xvx/Termux-Ubuntu-Installer/main/Themes/Win11-theme.sh
    bash Win11-theme.sh 
    rm ~/Win11-theme.sh 
    exit
    echo
EOF
    $login
    rm -rf $directory/.bashrc
}

macos_theme() {
    cat > $directory/.bashrc <<- EOF
    wget -nv https://raw.githubusercontent.com/23xvx/Termux-Ubuntu-Installer/main/Themes/MacOS-theme.sh 
    bash MacOS-theme.sh 
    rm ~/MacOS-theme.sh
    exit
    echo
EOF
    $login
    rm -rf $directory/.bashrc
}

apps() {
    if [[ "$desk" == "true" ]] ; then 
        clear 
        echo ${C}"Install Firefox Web Broswer? (y/n) "
        read browser 
        if [[ "$browser" =~ ^([yY])$ ]]; then
            echo ""
            echo ${G}"Installing Firefox Broswer ...." ${W}
            cat > $directory/.bashrc <<- EOF
            wget -nv https://raw.githubusercontent.com/23xvx/Termux-Ubuntu-Installer/main/Apps/firefox.sh
            bash firefox.sh 
            clear 
            vncstart 
            sleep 4
            DISPLAY=:1 firefox &
            sleep 10
            pkill -f firefox
            vncstop
            sleep 2
            exit 
            echo 
EOF
            $login 
            echo 'user_pref("sandbox.cubeb", false);
            user_pref("security.sandbox.content.level", 1);' >> $directory/.mozilla/firefox-esr/*esr102/prefs.js
            rm -rf $directory/.bashrc 
            clear 
        else 
            echo ""
            echo ${G}"Not installing , skip process.." ${W}
            echo 
            sleep 1
        fi  
        sleep 1 
        echo ${C}"Install Discord (Webcord)? (y/n) "
        read discord 
        if [[ "$discord" =~ ^([yY])$ ]]; then
            echo 
            echo ${G}"Installing Discord ...." ${W}
            cat > $directory/.bashrc <<- EOF
            wget -nv https://raw.githubusercontent.com/23xvx/Termux-Ubuntu-Installer/main/Apps/webcord.sh
            bash webcord.sh 
            sleep 2
            exit
            echo 
EOF
            $login 
            clear 
            rm $directory/.bashrc 
        else 
            echo 
            echo ${G}"Not installing , skip process.." ${W}
            sleep 1
            echo 
        fi  
        sleep 1 
        echo ${C}"Install VScode? (y/n) "
        read vscode
        if [[ "$vscode" =~ ^([yY])$ ]]; then
            echo 
            echo ${G}"Installing Vscode ...." ${W}
            cat > $directory/.bashrc <<- EOF
            wget -nv https://raw.githubusercontent.com/23xvx/Termux-Ubuntu-Installer/main/Apps/vscodefix.sh
            bash vscodefix.sh 
            sleep 2
            exit
            echo 
EOF
            $login 
            rm $directory/.bashrc 
            clear 
        else 
         echo 
        echo ${G}"Not installing , skip process.." ${W}
        sleep 1
        clear 
        fi  
fi 
}

fixes() {
    rm $PREFIX/bin/start-ubuntu* 
    echo "pulseaudio \
        --start --load='module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1'  \
        --exit-idle-time=-1" >> $PREFIX/bin/start-ubuntu 
    cp $PREFIX/bin/start-ubuntu $PREFIX/bin/start-ubuntu-tmp 
    if [[ "$user" =~ ^([yY])$ ]]; then
        echo "proot-distro login ubuntu --user $username" >> $PREFIX/bin/start-ubuntu 
        echo "proot-distro login ubuntu --user $username --shared-tmp" >> $PREFIX/bin/start-ubuntu-tmp
    else 
        echo "proot-distro login ubuntu " >> $PREFIX/bin/start-ubuntu 
        echo "proot-distro login ubuntu --shared-tmp " >> $PREFIX/bin/start-ubuntu-tmp 
    fi 
    chmod +x $PREFIX/bin/start-ubuntu*  
    rm $directory/.bashrc 
    mv $directory/.bak $directory/.bashrc 
    if [[ ! -f "$directory/.bashrc " ]]; then
        echo "rm ~/.bashrc ; cp /etc/skel/.bashrc . ; bash " >> $directory/etc/skel/.bashrc  
    fi 
    echo "export PULSE_SERVER=127.0.0.1" >> $directory/.bashrc
}

finish () {
    clear
    sleep 2
    echo ${G}"Installation Complete"
    echo ""
    echo " start-ubuntu      To Start Ubuntu  "
    echo "" 
    echo " start-ubuntu-tmp  To Start Ubuntu with --shared-tmp flag "
    echo ""
    if [[ "$desk" == "true" ]]; then 
    echo " vncstart          To start vncserver (In Ubuntu)"
    echo ""
    echo " vncstop           To stop vncserver (In Ubuntu)"
    echo ""     
    fi 
    echo ${Y}"Notice : You cannot install it by proot-distro after removing it."
}

requirements
choose_desktop
downloader
decompressing
configures
user
install_desktop
apps 
fixes
finish 

