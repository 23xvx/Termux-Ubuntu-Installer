#!/bin/bash
sudo apt update 
sudo apt install kde-plasma-desktop tigervnc-standalone-server -y
mkdir -p ~/.vnc
cat <<-  EOF > ~/.vnc/xstartup
#!/bin/bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADRESS
export PULSE_SERVER=127.0.0.1
service dbus start
dbus-launch startplasma-x11
EOF

echo "vncserver " >> /usr/local/bin/vncstart
echo "vncserver -kill :* ; rm -rf /tmp/.X1-lock ; rm -rf /tmp/.X11-unix/X1" >> /usr/local/bin/vncstop
chmod +x $HOME/.vnc/xstartup
chmod +x /usr/local/bin/vncstart 
chmod +x /usr/local/bin/vncstop
vncstart
sleep 60
vncstop