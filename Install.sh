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
echo ${G} "This is script will install ubuntu 23.04 (lunar) in proot-distro"
sleep 2
clear 

#requirements
echo ${G}"Installing requirements"${W}
pkg install wget proot-distro pulseaudio -y
termux-setup-storage
if [[ ! -d "$PREFIX/var/lib/proot-distro" ]]; then
    mkdir -p $PREFIX/var/lib/proot-distro
    mkdir -p $PREFIX/var/lib/proot-distro/installed-rootfs
fi 
echo
if [[ -d "$PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu" ]]; then
echo ${G}"Existing file found, are you sure to remove it? (y or n)"${W}
read ans
fi

#YES/NO
if [[ "$ans" =~ ^([yY])$ ]]
then
    echo ${W}"Deleting existing directory...."${W}
    proot-distro remove ubuntu 
    clear
    mkdir -p $PD/ubuntu 
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
echo ${G}"Please choose your desktop"${Y}
echo " 1) XFCE (Light Weight)"
echo " 2) GNOME (Default desktop of ubuntu) "
echo " 3) MATE (Stable)"
echo ${G}"Please press number 1/2/3 to choose your desktop "
echo ${G}"If you just want a CLI please press enter"${W}
read desktop 

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
    echo ${G}"Downloading rootfs"${W}
    wget "https://cloud-images.ubuntu.com/releases/23.04/release/ubuntu-23.04-server-cloudimg-${archurl}-root.tar.xz" -O $tarball
fi 
sleep 1
clear 
echo ${G}"Decompressing rootfs"${W}
proot --link2symlink  \
    tar --warning=no-unknown-keyword \
        --delay-directory-restore --preserve-permissions \
        -xpf ~/$tarball -C $PD/$ds_name --exclude='dev'||:
if [[ ! -d "$PD/$ds_name/bin" ]]; then
    mv $PD/$ds_name/*/* $PD/$ds_name/
fi
echo "127.0.0.1 localhost " >> $PD/$ds_name/etc/hosts
rm -rf $PD/$ds_name/etc/resolv.conf
echo "nameserver 8.8.8.8 " >> $PD/$ds_name/etc/resolv.conf
echo "touch .hushlogin" >> $PD/$ds_name/root/.bashrc
echo -e "#!/bin/sh\nexit" > "$PD/$ds_name/usr/bin/groups"
rm -rf $PD/$ds_name/etc/apt/apt.conf.d/99needrestart

cat > $PD/$ds_name/root/.bashrc <<- EOF
apt-get update
apt install udisks2 wget openssl neofetch -y
rm -rf /var/lib/dpkg/info/udisks2.postinst
echo "" >> /var/lib/dpkg/info/udisks2.postinst
dpkg --configure -a
apt-mark hold udisks2
exit
echo 
EOF
proot-distro login ubuntu 
rm -rf $PD/$ds_name/root/.bashrc

#Adding an user?
echo ${G}"Do you want to add a user (y/n)"
echo ${Y}"If you are going to install MATE Desktop, it is strongly reccommended to add a user "
echo "Because mate-menu crashes in root!"
read user 
if [[ "$user" =~ ^([yY])$ ]]; then
    echo ${G}"Please type in your username "${W}
    read username 
    directory=$PD/$ds_name/home/$username
    login="proot-distro login ubuntu --user $username" 
    echo ${G}"Do you want to set a password for your user (y/n)?"
    read pswd
    if [[ "$pswd" =~ ^([yY])$ ]]; then
        echo ${G}"Please type in a password for user"
        read password
        echo "Adding a user...."
        cat > $PD/$ds_name/root/.bashrc <<- EOF
        useradd -m -p "$(openssl passwd -1 ${password})" \
            -G sudo \
            -d /home/${username} \
            -k /etc/skel \
            -s /bin/bash \
            $username
        echo $username ALL=\(root\) ALL > /etc/sudoers.d/$username
        chmod 0440 /etc/sudoers.d/$username
        exit
        echo
EOF
    proot-distro login ubuntu 
    rm -rf $PD/$ds_name/root/.bashrc
    elif [[ "$pswd" =~ ^([nN])$ ]]; then
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
    else 
        echo ${R}"Cannot identify your answer"
        exit 1
    fi 
elif [[ "$user" =~ ^([nN])$ ]]; then
    echo ${G}"The installation will be completed as root"
    sleep 2
    clear
    directory=$PD/$ds_name/root
    login="proot-distro login ubuntu"
else 
    echo ${R}"Cannot identify your answer"
    exit 
fi 

#Installing Desktop 
if [[ "$desktop" =~ ^([1])$ ]]; then 
    echo ${G}"Installing XFCE Desktop..."${W}
    cat > $directory/.bashrc <<- EOF
    wget https://raw.githubusercontent.com/23xvx/Termux-Ubuntu-Installer/main/Desktop/xfce.sh
    bash xfce.sh 
    exit
    echo
EOF
    exec $login
    rm -rf $directory/.bashrc
elif [[ "$desktop" =~ ^([2])$ ]]; then 
    sleep 1
    clear 
    echo ${G}"Installing GNOME Desktop..."${W}
    cat > $directory/.bashrc <<- EOF
    wget https://raw.githubusercontent.com/23xvx/Termux-Ubuntu-Installer/main/Desktop/gnome.sh
    bash gnome.sh 
    exit
    echo
EOF
    exec $login
    rm -rf $directory/.bashrc
elif [[ "$desktop" =~ ^([3])$ ]]; then 
    sleep 1
    clear 
    echo ${G}"Installing GNOME Desktop..."${W}
    cat > $directory/.bashrc <<- EOF
    wget https://raw.githubusercontent.com/23xvx/Termux-Ubuntu-Installer/main/Desktop/mate.sh
    bash mate.sh 
    exit
    echo
EOF
    exec $login
    rm -rf $directory/.bashrc
else 
    echo 
fi 


#Installing Browser 
echo ${G}"Installing Browser...." ${W}
cat > $directory/.bashrc <<- EOF
echo "deb http://ftp.debian.org/debian stable main contrib non-free" >> /etc/apt/sources.list
apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv-keys 648ACFD622F3D138
apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv-keys 0E98404D386FA1D9
apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv-keys 605C66F00D6C9793
apt update
apt install firefox-esr -y 
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
exec $login 
wget -O $(find $directory/.mozilla/firefox -name *.default-esr)/user.js https://raw.githubusercontent.com/23xvx/Termux-Ubuntu-Installer/main/Configures/user.js
rm -rf $directory/.bashrc

#Fixing sound 
echo "export PULSE_SERVER=127.0.0.1" >> $directory/.bashrc

#Writing Startup Script 
echo "pulseaudio \
    --start --load='module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1'  \
    --exit-idle-time=-1" >> $PREFIX/bin/start-ubuntu 
if [[ "$user" =~ ^([yY])$ ]]; then
    echo "proot-distro login ubuntu --user $username" >> $PREFIX/bin/start-ubuntu 
else 
    echo "proot-distro login ubuntu " >> $PREFIX/bin/start-ubuntu 
fi 
chmod +x $PREFIX/bin/start-ubuntu 
clear

#Finish
sleep 2
echo ${G}"Installation Finish!"
echo ${G}"Now you can login to your distro by executing 'start-ubuntu'"
echo ${R}"Notice : You cannot install it by proot-distro after removing it."




