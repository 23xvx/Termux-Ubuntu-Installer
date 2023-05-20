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
elif [[ "$ans" =~ ^([nN])$ ]]
then
    echo ${R}"Sorry, but we cannot complete the installation"
    exit 1
else 
    echo
    clear
fi

#Downloading and Decompressing rootfs
tarball="ubuntu-rootfs.tar.xz"
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
wget "https://cloud-images.ubuntu.com/releases/22.04/release/ubuntu-22.04-server-cloudimg-${archurl}-root.tar.xz" -O $tarball
echo ${G}"Decompressing rootfs"
proot --link2symlink  \
    tar --warning=no-unknown-keyword \
        --delay-directory-restore --preserve-permissions \
        -xpf ~/$tarball -C $PD/$ds_name/ --exclude='dev'||:
rm -rf ~/$tarball
if [[ ! -d "$PD/$ds_name/bin" ]]; then
     mv $PD/$ds_name/*/* $PD/$ds_name/
fi
echo "127.0.0.1 localhost " >> $PD/$ds_name/etc/hosts
rm -rf $PD/$ds_name/etc/resolv.conf
echo "nameserver 8.8.8.8 " >> $PD/$ds_name/etc/resolv.conf
echo "touch .hushlogin" >> $PD/$ds_name/root/.bashrc
echo -e "#!/bin/sh\nexit" > "$PD/$ds_name/usr/bin/groups"

#choosing desktop 
echo ${G}"Please choose your desktop"${W}
echo " 1) XFCE "
echo " 2) GNOME "
echo " 3) MATE "
echo ${G}"Please press number 1/2/3 to choose your desktop "${W}
read desktop 

#Installing Desktop 
if [[ "$desktop" =~ ^([1])$ ]]; then 
sleep 1
clear 
echo ${G}"Installing XFCE Desktop..."${W}
cat > $PD/$ds_name/root/.bashrc <<- EOF
apt-get update
apt install udisks2 wget -y
rm -rf /var/lib/dpkg/info/udisks2.postinst
echo "" >> /var/lib/dpkg/info/udisks2.postinst
dpkg --configure -a
apt-mark hold udisks2
wget http://raw.githubusercontent.com/23xvx/Termux-Ubuntu-Installer/main/Desktop/xfce.sh
bash xfce.sh 
exit
echo
EOF
proot-distro login ubuntu 
rm -rf $PD/$ds_name/root/.bashrc
elif [[ "$desktop" =~ ^([2])$ ]]; then 
sleep 1
clear 
echo ${G}"Installing GNOME Desktop..."${W}
cat > $PD/$ds_name/root/.bashrc <<- EOF
apt-get update
apt install udisks2 wget -y
rm -rf /var/lib/dpkg/info/udisks2.postinst
echo "" >> /var/lib/dpkg/info/udisks2.postinst
dpkg --configure -a
apt-mark hold udisks2
wget http://raw.githubusercontent.com/23xvx/Termux-Ubuntu-Installer/main/Desktop/gnome.sh
bash gnome.sh 
exit
echo
EOF
proot-distro login ubuntu 
rm -rf $PD/$ds_name/root/.bashrc