#!/bin/sh 
# source by udroid 
sudo apt update
sudo apt install gpg software-properties-common -y
sudo add-apt-repository --yes ppa:mozillateam/ppa
echo '
Package: *
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001
' >> /etc/apt/preferences.d/mozilla-firefox
echo 'Unattended-Upgrade::Allowed-Origins:: "LP-PPA-mozillateam:${distro_codename}";'>> /etc/apt/apt.conf.d/51unattended-upgrades-firefox
sudo apt update 
sudo apt remove firefox -y
sudo apt install firefox-esr -y
rm -rf firefox.sh 