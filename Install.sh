#!/data/data/com.termux/files/usr/bin/bash

PD=$PREFIX/var/lib/proot-distro/installed-rootfs
ds_name=ubuntu 

#Adding colors
R="$(printf '\033[1;31m')"
G="$(printf '\033[1;32m')"
Y="$(printf '\033[1;33m')"
W="$(printf '\033[1;37m')"
C="$(printf '\033[1;36m')"

#clear
clear

#Notice 
echo ${G}"This script will install ubuntu 23.04 (Lunar) in proot-distro"
echo ${C}"Script by No Hope#0281"
sleep 2
clear 

#requirements
echo ${G}"Installing requirements"${W}
pkg install wget proot-distro pulseaudio -y
clear 
echo ${C}"Please allow storage permission"${W}
termux-setup-storage
if [[ ! -d "$PREFIX/var/lib/proot-distro" ]]; then
    mkdir -p $PREFIX/var/lib/proot-distro
    mkdir -p $PREFIX/var/lib/proot-distro/installed-rootfs
fi 
echo
if [[ -d "$PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu" ]]; then
echo ${C}"Existing file found, are you sure to remove it? (y or n)"${W}
read ans
fi

#YES/NO
if [[ "$ans" =~ ^([yY])$ ]]
then
    echo ${W}"Deleting existing directory...."${W}
    proot-distro remove ubuntu 
    if [[ -d "$PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu" ]]; then
        echo ${R}"Cannot remove existing file, exiting...."
        exit 1
    fi 
    mkdir -p $PD/ubuntu 
    clear 
elif [[ "$ans" =~ ^([nN])$ ]]
then
    echo ${R}"Sorry, but we cannot complete the installation"
    exit 1
else 
    echo
    mkdir $PD/ubuntu 
    clear
fi

#choosing desktop 
echo ${C}"Please choose your desktop"${Y}
echo " 1) XFCE (Light Weight)"
echo " 2) GNOME (Default desktop of ubuntu) "
echo " 3) MATE (Stable)"
echo ${C}"Please press number 1/2/3 to choose your desktop "
echo ${C}"If you just want a CLI please press enter"${W}
read desktop 
sleep 1

#Downloading and Decompressing rootfs
tarball="lunar.tar.xz"
if [ ! -f $tarball ]; then
    case `dpkg --print-architecture` in
        aarch64)
            archurl="arm64" ;;
        arm*)
            archurl="armhf" ;;
        ppc64el)
            archurl="ppc64el" ;;
        x86_64)
            archurl="amd64" ;;
        *)
            echo "unknown architecture"; exit 1 ;;
    esac
    clear 
    echo ${G}"Downloading rootfs"${W}
    wget "https://cloud-images.ubuntu.com/releases/23.04/release/ubuntu-23.04-server-cloudimg-${archurl}-root.tar.xz" -O $tarball
else 
    echo " " 
    echo ${G}"Existing file found, skip downloading..."
    sleep 1 
fi 
echo ""
echo ${Y}"Delete Downloaded file? (y/n)" 
read del 
if [[ "$del" =~ ^([yY])$ ]]; then 
echo ${y}"Deleting ...."
rm -rf $tarball 
fi 
sleep 1
echo ""
echo ${G}"Decompressing rootfs"${W}
proot --link2symlink  \
    tar --warning=no-unknown-keyword \
        --delay-directory-restore --preserve-permissions \
        -xpf ~/$tarball -C $PD/$ds_name --exclude='dev'||:
if [[ ! -d "$PD/$ds_name/bin" ]]; then
    mv $PD/$ds_name/*/* $PD/$ds_name/
fi

#Configures 
echo "127.0.0.1 localhost " >> $PD/$ds_name/etc/hosts
rm -rf $PD/$ds_name/etc/resolv.conf
echo "nameserver 8.8.8.8 " >> $PD/$ds_name/etc/resolv.conf
echo "touch .hushlogin" >> $PD/$ds_name/root/.bashrc
echo -e "#!/bin/sh\nexit" > "$PD/$ds_name/usr/bin/groups"
rm -rf $PD/$ds_name/etc/apt/apt.conf.d/99needrestart
clear 
mv $PD/$ds_name/root/.bashrc $PD/$ds_name/root/.bash 
echo ${G}"Installing requirements in ubuntu ..."${W}
cat > $PD/$ds_name/root/.bashrc <<- EOF
apt-get update
apt install sudo nano udisks2 wget openssl neofetch -y
rm -rf /var/lib/dpkg/info/udisks2.postinst
echo "" >> /var/lib/dpkg/info/udisks2.postinst
dpkg --configure -a
apt-mark hold udisks2
exit
echo 
EOF
proot-distro login ubuntu 
rm -rf $PD/$ds_name/root/.bashrc

#Adding an user
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
    mv $PD/$ds_name/root/.bash $PD/$ds_name/root/.bashrc 
    sleep 2 
elif [[ "$user" =~ ^([nN])$ ]]; then
    sleep 1
    echo ""
    echo ${G}"The installation will be completed as root"
    sleep 2
    clear
    directory=$PD/$ds_name/root
    login="proot-distro login ubuntu"
    mv $PD/$ds_name/root/.bash $PD/$ds_name/root/.bashrc 
else 
    echo ${R}"Cannot identify your answer"
    exit 
fi 

#Installing Desktop 
if [[ "$desktop" =~ ^([1])$ ]]; then
    clear 
    echo ${G}"Installing XFCE Desktop..."${W}
    mv $directory/.bashrc $directory/.bak 
    cat > $directory/.bashrc <<- EOF
    wget https://raw.githubusercontent.com/23xvx/Termux-Ubuntu-Installer/main/Desktop/xfce.sh
    bash xfce.sh 
    exit
    echo
EOF
    $login
    rm -rf $directory/.bashrc
elif [[ "$desktop" =~ ^([2])$ ]]; then 
    sleep 1
    clear 
    echo ${G}"Installing GNOME Desktop..."${W}
    mv $directory/.bashrc $directory/.bak 
    cat > $directory/.bashrc <<- EOF
    wget https://raw.githubusercontent.com/23xvx/Termux-Ubuntu-Installer/main/Desktop/gnome.sh
    bash gnome.sh 
    exit
    echo
EOF
    $login
    rm -rf $directory/.bashrc
elif [[ "$desktop" =~ ^([3])$ ]]; then 
    mv $directory/.bashrc $directory/.bak 
    sleep 1
    clear 
    echo ${G}"Installing Mate Desktop..."${W}
    cat > $directory/.bashrc <<- EOF
    wget https://raw.githubusercontent.com/23xvx/Termux-Ubuntu-Installer/main/Desktop/mate.sh
    bash mate.sh 
    exit
    echo
EOF
    $login
    rm -rf $directory/.bashrc
else 
    echo 
fi 


#Installing Personal Applications 
if [[ "$desktop" =~ ^([1])$ ]] || [[ "$desktop" =~ ^([2])$ ]] || [[ "$desktop" =~ ^([3])$ ]]; then 
    echo ${C}"Install Firefox Web Broswer? (y/n) "
    read browser 
    if [[ "$browser" =~ ^([yY])$ ]]; then
        echo ""
        echo ${G}"Installing Fiefox Broswer ...." ${W}
        cat > $directory/.bashrc <<- EOF
        wget https://raw.githubusercontent.com/23xvx/Termux-Ubuntu-Installer/main/Apps/firefox.sh
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
        wget -O $(find $directory/.mozilla/firefox -name *.default-esr)/user.js https://raw.githubusercontent.com/23xvx/Termux-Ubuntu-Installer/main/Configures/user.js
        rm -rf $directory/.bashrc 
        clear 
    else 
    echo ""
    echo ${G}"Not installing , skip process.." ${W}
    sleep 1
    clear 
    fi 
    sleep 1 
    echo ${C}"Install Discord (Webcord)? (y/n) "
    read discord 
    if [[ "$discord" =~ ^([yY])$ ]]; then
        echo 
        echo ${G}"Installing Discord ...." ${W}
        cat > $directory/.bashrc <<- EOF
        wget https://raw.githubusercontent.com/23xvx/Termux-Ubuntu-Installer/main/Apps/webcord.sh
        bash webcord.sh 
        sleep 2
        exit
        echo 
EOF
        $login 
        clear 
        rm $directory/.bashrc 
    else 
    echo ${G}"Not installing , skip process.." ${W}
    sleep 1
    clear 
    fi  
    sleep 1 
    echo ${C}"Install VScode? (y/n) "
    read vscode
    if [[ "$vscode" =~ ^([yY])$ ]]; then
        echo 
        echo ${G}"Installing Vscode ...." ${W}
        cat > $directory/.bashrc <<- EOF
        wget https://raw.githubusercontent.com/23xvx/Termux-Ubuntu-Installer/main/Apps/vscodefix.sh
        bash vscodefix.sh 
        sleep 2
        exit
        echo 
EOF
        $login 
        rm $directory/.bashrc 
        clear 
    else 
    echo ${G}"Not installing , skip process.." ${W}
    sleep 1
    clear 
    fi  
fi 

#Fixing sound 
echo "export PULSE_SERVER=127.0.0.1" >> $directory/.bashrc

#Writing Startup Script 
rm $PREFIX/bin/start-ubuntu* 
echo "pulseaudio \
    --start --load='module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1'  \
    --exit-idle-time=-1" >> $PREFIX/bin/start-ubuntu 
cp $PREFIX/bin/start-ubuntu $PREFIX/bin/start-ubuntu-x11 
if [[ "$user" =~ ^([yY])$ ]]; then
    echo "proot-distro login ubuntu --user $username" >> $PREFIX/bin/start-ubuntu 
    echo "proot-distro login ubuntu --user $username --shared-tmp" >> $PREFIX/bin/start-ubuntu-x11
else 
    echo "proot-distro login ubuntu " >> $PREFIX/bin/start-ubuntu 
    echo "proot-distro login ubuntu --shared-tmp " >> $PREFIX/bin/start-ubuntu-x11 
fi 
chmod +x $PREFIX/bin/start-ubuntu*  
rm $directory/.bashrc 
mv $directory/.bak $directory/.bashrc 
clear

#Finish
sleep 2
echo ${G}"Installation Complete"
echo ""
echo " start-ubuntu      To Start Ubuntu  "
echo "" 
echo " start-ubuntu-x11  To Start Ubuntu with --shared-tmp flag "
echo ""
echo " vncstart          To start vncserver (In Ubuntu)"
echo ""
echo " vncstop           To stop vncserver (In Ubuntu)"
echo "" 
echo ${Y}"Notice : You cannot install it by proot-distro after removing it."




