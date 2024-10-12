### Using desktops

# VNC 
1. Install a vncviewer app to access desktop installed
2. Start vncserver in ubuntu using `vncstart`
3. Open the vncviewer app and connect to it

# Termux:X11
1. Download termux:X11 apk from [github](https://github.com/termux/termux-x11/releases/latest) and install
2. Install termux-x11 package in termux:

```bash
apt update && apt install termux-x11-nightly -y
```

3. Allow external apps access in termux
```bash
sed -i s/'# allow-external-apps = true'/'allow-external-apps = true'/g ~/.termux/termux.properties
```

4. Start termux-x11 in termux and open ubuntu
```bash
termux-x11 :1
# Open another session and login to ubuntu
start-ubuntu
```

5. Export DISPLAY and start desktop
```bash
export DISPLAY=:1
export PULSE_SERVER=127.0.0.1
```

- XFCE (including macos)
```bash
dbus-launch xfce4-session
```

- GNOME (including win11)
<p> - shell version (quicker to startup,stable) </p>

```bash
export XDG_SESSION_TYPE=x11
export XDG_CURRENT_DESKTOP=GNOME
service dbus start
dbus-launch gnome-shell
```
<p> - session version (unstable,icons applied correctly)</p>

```bash
export XDG_SESSION_TYPE=x11
export XDG_CURRENT_DESKTOP=GNOME
service dbus start
dbus-launch gnome-session
```

- MATE
```bash
dbus-launch mate-session
```

- KDE (including win10)
```bash
service dbus start
dbus-launch startplasma-x11
```

- Cinnamon
```bash
service dbus start
dbus-launch cinnamon-session
```

 
