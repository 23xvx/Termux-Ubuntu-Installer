#!/bin/sh 
# code from https://code.visualstudio.com/docs/setup/linux
sudo apt-get update 
sudo apt-get install wget gpg -y 
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg
sudo apt install apt-transport-https -y 
sudo apt update
sudo apt install code -y 
sed -i 's/%F/--no-sandbox %F/g' /usr/share/applications/code.desktop 
rm -rf $HOME/vscodefix.sh 
