#!/bin/zsh

# Colours
G="$(printf '\033[1;32m')"
W="$(printf '\033[1;37m')"
Y="$(printf '\033[1;33m')"

echo ${G}"Ubuntu mein Full XFCE Desktop install ho raha hai..."${W}

# 1. Update aur icon theme fix
sudo apt update 
sudo apt-mark hold elementary-xfce-icon-theme

# 2. Full XFCE aur zaroori tools install karna
sudo apt install xfce4 xfce4-goodies xfce4-terminal dbus-x11 tigervnc-standalone-server xfce4-appmenu-plugin -y

# 3. vncstart command banana
sudo bash -c 'cat > /usr/local/bin/vncstart' <<EOF
#!/bin/zsh
export DISPLAY=:1
export PULSE_SERVER=127.0.0.1
service dbus start > /dev/null 2>&1
vncserver -localhost no -geometry 1280x720 -xstartup /usr/bin/startxfce4 :1
EOF

# 4. vncstop command banana
sudo bash -c 'cat > /usr/local/bin/vncstop' <<EOF
#!/bin/zsh
vncserver -kill :* > /dev/null 2>&1
rm -rf /tmp/.X1-lock
rm -rf /tmp/.X11-unix/X1
echo "VNC Server band ho gaya hai."
EOF

# 5. Permissions set karna
sudo chmod +x /usr/local/bin/vncstart 
sudo chmod +x /usr/local/bin/vncstop 

clear 
echo ${Y}"Bhai, apna VNC Password set karo (kam se kam 6 characters)"${W}
# Yahan password manga jayega
vncpasswd

# 6. Initial test run (Start -> Wait -> Stop)
echo ${G}"Testing VNC Server, thoda intezar karein..."${W}
vncstart
sleep 4
vncstop

clear
echo ${G}"Setup complete! Ab tum 'vncstart' likh kar desktop chala sakte ho."${W}