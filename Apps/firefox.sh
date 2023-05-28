#!/bin/sh 
echo "deb http://ftp.debian.org/debian stable main contrib non-free" >> /etc/apt/sources.list
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv-keys 648ACFD622F3D138
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv-keys 0E98404D386FA1D9
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv-keys 605C66F00D6C9793
sudo apt-get update
sudo apt-get install firefox-esr -y 
mv /etc/apt/trusted.gpg /etc/apt/trusted.gpg.d/
rm -rf firefox.sh 
