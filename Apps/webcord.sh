#!/bin/sh 
sudo apt-get update 
sudo apt-get install wget -y 
case `uname -m` in
    aarch64)
        archurl="arm64" ;;
    arm*)
        archurl="armhf" ;;
    x86)
        archurl="amd64" ;;
    x86_64)
        archurl="amd64" ;;
    *)
        archurl="x" ;;
esac 
if [ "$archurl" =~ ^([x])$]; then 
    echo "Unsupported architecture, cannot install discord" 
else 
    wget https://github.com/SpacingBat3/WebCord/releases/download/v4.2.0/webcord_4.2.0_${archurl}.deb -P $HOME/
    sudo apt install ./webcord_4.2.0_${archurl}.deb 
    rm -rf *.deb 
    sed -i 's/%U/--no-sandbox %U/g' /usr/share/applications/webcord.desktop 
fi 
rm -rf webcord.sh 
