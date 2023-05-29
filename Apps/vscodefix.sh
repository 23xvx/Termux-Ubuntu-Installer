#!/bin/sh 
apt-get update 
case `uname -m` in
    aarch64)
        archurl="arm64" ; 
        wget "https://az764295.vo.msecnd.net/stable/704ed70d4fd1c6bd6342c436f1ede30d1cff4710/code_1.77.3-1681295476_${archurl}.deb" -P $HOME;;
    arm*)
        archurl="armhf" ;
        wget "https://az764295.vo.msecnd.net/stable/704ed70d4fd1c6bd6342c436f1ede30d1cff4710/code_1.77.3-1681291917_${archurl}.deb" -P $HOME;;
    x86)
        archurl="amd64" 
        wget "https://az764295.vo.msecnd.net/stable/704ed70d4fd1c6bd6342c436f1ede30d1cff4710/code_1.77.3-1681292746_${archurl}.deb" -P $HOME;;
    x86_64)
        archurl="amd64" ; 
        wget "https://az764295.vo.msecnd.net/stable/704ed70d4fd1c6bd6342c436f1ede30d1cff4710/code_1.77.3-1681292746_${archurl}.deb" -P $HOME;;
    *)
        archurl="x" ;
esac
if [ "$archurl" =~ ^([x])$]; then 
    echo "Unsupported architecture, cannot install VScode" 
else 
    sudo apt install ./code*
    sleep 1
    rm ./*.deb 
    sed -i 's/%F/--no-sandbox %F/g' /usr/share/applications/code.desktop 
fi 
rm -rf $HOME/vscodefix.sh 
