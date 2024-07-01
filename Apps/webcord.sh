#!/bin/sh
sudo apt-get update
sudo apt-get install wget -y
case `uname -m` in
    aarch64)
        archurl="arm64" ;;
    arm*)
        archurl="armhf" ;;
    x86*)
        archurl="amd64" ;;
    *)
        echo "Unsupported architecture, cannot install discord" ; exit 1 ;;
esac
latest_release=$(curl -s -I https://github.com/SpacingBat3/WebCord/releases/latest | grep location | awk -F '/' '/^location/ {print  substr($NF, 1, length($NF)-1)}')
latest_tag=$(echo $latest_release | tr -d "v")
wget -q --show-progress https://github.com/SpacingBat3/WebCord/releases/download/${latest_release}/webcord_${latest_tag}_${archurl}.deb -P $HOME/
sudo apt install ./webcord_${latest_tag}_${archurl}.deb -y
sed -i 's/%U/--no-sandbox %U/g' /usr/share/applications/webcord.desktop
rm -rf *.deb
rm -rf webcord.sh
