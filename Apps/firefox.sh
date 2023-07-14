#!/bin/sh 
#source by udroid 
apt update 
sudo apt install -y firefox
rm -rf /etc/apt/preferences.d/fire*
sudo apt remove firefox* -y
sudo apt update && apt install firefox software-properties-common -y
sudo add-apt-repository --yes ppa:mozillateam/ppa
echo '
Package: *
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001
' >> /etc/apt/preferences.d/mozilla-firefox
echo 'Unattended-Upgrade::Allowed-Origins:: "LP-PPA-mozillateam:${distro_codename}";'>> /etc/apt/apt.conf.d/51unattended-upgrades-firefox
apt update 
apt remove firefox -y
apt install firefox -y
mv /etc/apt/trusted.gpg /etc/apt/trusted.gpg.d/ 
rm -rf firefox.sh 