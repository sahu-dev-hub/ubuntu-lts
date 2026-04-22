#!/bin/zsh

# Colours
G="$(printf '\033[1;32m')"
W="$(printf '\033[1;37m')"
Y="$(printf '\033[1;33m')"

echo ${G}"Ubuntu mein MATE Desktop install ho raha hai..."${W}

# 1. Update aur Desktop Environment install karna
sudo apt update 
sudo apt install mate-desktop-environment mate-terminal mate-tweak -y
sudo apt install yaru-theme-gtk yaru-theme-icon tigervnc-standalone-server ubuntu-wallpapers dconf-cli -y 

# 2. vncstart command banana
sudo bash -c 'cat > /usr/local/bin/vncstart' <<EOF
#!/bin/zsh
export DISPLAY=:1
export PULSE_SERVER=127.0.0.1
service dbus start > /dev/null 2>&1
vncserver -localhost no -geometry 1280x720 -xstartup /usr/bin/mate-session :1
EOF

# 3. vncstop command banana
sudo bash -c 'cat > /usr/local/bin/vncstop' <<EOF
#!/bin/zsh
vncserver -kill :* > /dev/null 2>&1
rm -rf /tmp/.X1-lock
rm -rf /tmp/.X11-unix/X1
echo "VNC Server band ho gaya hai."
EOF

sudo chmod +x /usr/local/bin/vncstart 
sudo chmod +x /usr/local/bin/vncstop 

clear 
echo ${Y}"Bhai, apna VNC Password set karo (kam se kam 6 characters)"${W}
vncpasswd

# 4. Themes apply karne ke liye Start -> Wait -> Config -> Stop
echo ${G}"Themes aur settings apply ho rahi hain..."${W}
vncstart
sleep 5 # Intezar taaki session load ho jaye

# Ab dconf commands chalenge jab server ON hai
DISPLAY=:1 dbus-launch dconf write /org/mate/desktop/interface/gtk-theme "'Yaru-MATE-dark'"
DISPLAY=:1 dbus-launch dconf write /org/mate/marco/general/theme "'Yaru-MATE-dark'"
DISPLAY=:1 dbus-launch dconf write /org/mate/desktop/interface/icon-theme "'Yaru-MATE-dark'"
DISPLAY=:1 dbus-launch dconf write /org/mate/desktop/peripherals/mouse/cursor-theme "'Yaru-MATE-dark'"
DISPLAY=:1 dbus-launch dconf write /org/mate/desktop/background/picture-filename "'/usr/share/backgrounds/warty-final-ubuntu.png'"

sleep 2
vncstop

clear
echo ${G}"MATE Setup complete! Ab tum 'vncstart' likh kar maze lo."${W}