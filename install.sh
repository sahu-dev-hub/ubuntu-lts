#!/data/data/com.termux/files/usr/bin/bash

PD=$PREFIX/var/lib/proot-distro/installed-rootfs
ds_name=ubuntu-lts

clear

# Colours
R="$(printf '\033[1;31m')"
G="$(printf '\033[1;32m')"
Y="$(printf '\033[1;33m')"
W="$(printf '\033[1;37m')"
C="$(printf '\033[1;36m')"

## ask() - prompt the user with a message and wait for a Y/N answer
ask() {
    local msg=$*
    echo -ne "$msg\t[y/n]: "
    read -r choice
    case $choice in
        y|Y|yes) return 0;;
        n|N|No) return 1;;
        "") return 0;;
        *) return 1;;
    esac
}

## download_script() - download a script online
download_script() {
    local url=$1
    local dir=$2
    local mode=$3
    script=$(echo $url | awk -F / '{print $NF}')
    case $mode in
        verbose) WGET="wget --show-progress" ;;
        silence) WGET="wget -q --show-progress" ;;
        *) WGET="wget" ;;
    esac
    $WGET $url -P $dir
}

# 1. Sabse pehle ZSH install aur setup hoga
setup_zsh() {
    echo ${G}"Step 1: ZSH install aur setup ho raha hai, thoda wait karo..."${W}
    # ye zsh_setup.sh link hai
    download_script "https://raw.githubusercontent.com/sahu-dev-hub/ubuntu-lts/refs/heads/main/Setups/zsh_setup.sh" "$HOME" silence
    bash "$HOME/zsh_setup.sh"
    rm "$HOME/zsh_setup.sh"
    sleep 1
}

# Install proot-distro
requirements() {
    echo ${G}"Ye script proot-distro mein Ubuntu install karegi"
    sleep 1 
    echo ${G}"Zaroori packages install ho rahe hain..."${W}
    pkg install pulseaudio proot-distro wget -y
    [[ ! -d "$HOME/storage" ]] && {
        echo ${C}"Bhai, storage permission allow kar dena"${W}
        termux-setup-storage
    }
    [[ ! -d "$PREFIX/var/lib/proot-distro" ]] && {
        mkdir -p $PREFIX/var/lib/proot-distro
        mkdir -p $PREFIX/var/lib/proot-distro/installed-rootfs
    }
    echo

    if [[ ! -f "$PREFIX/etc/proot-distro/$ds_name.sh" ]]; then
        download_script "https://raw.githubusercontent.com/sahu-dev-hub/ubuntu-lts/refs/heads/main/ubuntu-lts.sh" "$PREFIX/etc/proot-distro/" silence
    fi

    [[ -d "$PD/$ds_name" ]] && {
        if ask ${Y}"Pehle se Ubuntu install hai, kya ise delete karke naya install karein?"${W}; then
            echo ""
            echo ${Y}"Purani directory delete ho rahi hai...."${W}
            proot-distro remove ubuntu-lts || ( echo ${R}"Purani directory remove nahi ho payi.." && exit 1 )
        else
            echo ${R}"Sorry bhai, installation cancel kar di gayi hai"
            exit 1
        fi
    }
}

# Pick desktop ( XFCE aur MATE)
choose_desktop() {
    clear
    echo ${C}"Koi Bhi Ek Desktop chuno"${Y}
    echo " 1) XFCE (Light Weight aur Fast)"
    echo " 2) MATE (Classic Look)"
    echo ${C}"Desktop chunne ke liye 1-2 enter karo"
    echo ${C}"Agar Desktop nahi chahiye toh sirf '${W}CLI${C}' likho"${W}
    read desktop
    sleep 1
    case $desktop in
        1|2) echo ${G}"Chalo bhai, installation shuru karte hain"${Y} ;;
        CLI) echo ${G}"Theek hai, sirf basic Ubuntu install hoga..."${Y} ;;
        *) echo ${R}"Galat option chuna hai"; sleep 1 ; choose_desktop ;;
    esac
}

# Install and Setup ubuntu 
configures() {
    proot-distro install ubuntu-lts
    echo ${G}"Ubuntu ke andar zaroori files install ho rahi hain..."${W}
    # Ubuntu ke andar zsh install kar rahe hain default ke liye
    cat > $PD/$ds_name/root/.bashrc <<- EOF
    apt-get update
    apt-get upgrade -y
    apt install sudo nano wget openssl git zsh -y
    exit
EOF
    proot-distro login ubuntu-lts
    rm -rf $PD/$ds_name/root/.bashrc
}

# Ask if setup a user
user() {
    clear
    if ask ${C}"Kya aap apna naya user banana chahte hain?"${W}; then
        echo ""
        echo ${C}"Username type karein (lowercase me): "${W}
        read username
        directory=$PD/$ds_name/home/$username
        login="proot-distro login ubuntu-lts --user $username"
        echo ""
        sleep 1
        echo ${G}"ZSH shell ke saath naya user ban raha hai ...."
        cat > $PD/$ds_name/root/.bashrc <<- EOF
        useradd -m \
            -G sudo \
            -d /home/${username} \
            -k /etc/skel \
            -s /bin/zsh \
            $username
        echo $username ALL=\(root\) ALL > /etc/sudoers.d/$username
        chmod 0440 /etc/sudoers.d/$username
        echo "$username ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
        exit
EOF
        proot-distro login ubuntu-lts
        rm -rf $PD/$ds_name/root/.bashrc
        sleep 2
        [[ ! -d $directory ]] && {
            echo -e ${R}"User nahi ban paya\nAb root user se hi kaam chalana padega"
            directory=$PD/$ds_name/root
            login="proot-distro login ubuntu-lts"
        }
    else
        echo ""
        echo ${G}"Installation root user se hi complete hogi"
        sleep 2
        directory=$PD/$ds_name/root
        login="proot-distro login ubuntu-lts"
    fi 
}

# install specific desktop
install_desktop() {
    desk=true
    case $desktop in
        1) xfce_mode ;;
        2) mate_mode ;;
        *) echo ${G}"Koi Desktop nahi chuna, skipping ...." ; desk=false ; sleep 2 ;;
    esac
    
    if $desk ; then 
        apps
    fi
}

xfce_mode() {
    echo ${G}"XFCE Desktop install ho raha hai..."${W}
    download_script "https://raw.githubusercontent.com/sahu-dev-hub/ubuntu-lts/refs/heads/main/Desktop/xfce.sh" $directory silence
    $login -- /bin/zsh xfce.sh
    rm -rf $directory/xfce.sh
}

mate_mode() {
    echo ${G}"Mate Desktop install ho raha hai..."${W}
    download_script "https://raw.githubusercontent.com/sahu-dev-hub/ubuntu-lts/refs/heads/main/Desktop/mate.sh" $directory silence
    $login -- /bin/zsh mate.sh
    rm -rf $directory/mate.sh
}

# Install external apps
apps() {
    clear
    if ask ${C}"Firefox Web Browser install karna hai?"${W}; then
        echo -e ${G}"\nFirefox Browser install ho raha hai ...." ${W}
        download_script "https://raw.githubusercontent.com/sahu-dev-hub/ubuntu-lts/refs/heads/main/Setups/firefox.sh" $directory silence
        [[ -f $directory/.zshrc ]] && mv $directory/.zshrc $directory/.zbak
        cat > $directory/.zshrc <<- EOF
        zsh firefox.sh 
        clear 
        vncstart 
        sleep 4
        DISPLAY=:1 firefox-esr &
        sleep 10
        pkill -f firefox-esr
        vncstop
        sleep 2
        exit 
        
EOF
        $login 
        echo 'user_pref("sandbox.cubeb", false);
        user_pref("security.sandbox.content.level", 1);' >> $directory/.mozilla/firefox-esr/*default-esr*/prefs.js
        rm -rf $directory/.zshrc
        mv $directory/.zbak $directory/.zshrc

        clear
        sleep 1
    else 
        echo -e ${Y}"\nThik hai bhai, skip kar diya..\n" ${W}
        sleep 1
    fi

    fi

    if ask ${C}"Discord (Webcord) install karna hai?"${W}; then
        echo -e ${G}"\nDiscord install ho raha hai ...." ${W}
        download_script "https://raw.githubusercontent.com/sahu-dev-hub/ubuntu-lts/refs/heads/main/Setups/webcord.sh" $directory silence
        $login -- /bin/zsh webcord.sh
        rm $directory/webcord.sh

        clear

    else 
        echo -e ${Y}"\nThik hai bhai, skip kar diya..\n" ${W}
        sleep 1

    fi

    if ask ${C}"Gimp (Photo editor) install karna hai?"${W}; then
        echo -e ${G}"\nGimp install ho raha hai ...." ${W}
        download_script "https://raw.githubusercontent.com/sahu-dev-hub/ubuntu-lts/refs/heads/main/Setups/gimp.sh" $directory silence
        $login -- /bin/zsh gimp.sh
        rm $directory/gimp.sh

        clear
        
    else 
        echo -e ${Y}"\nThik hai bhai, skip kar diya..\n" ${W}
        sleep 1

    fi

    if ask ${C}"VScode install karna hai?"${W}; then
        echo -e ${G}"\nVScode install ho raha hai ...." ${W}
        download_script "https://raw.githubusercontent.com/sahu-dev-hub/ubuntu-lts/refs/heads/main/Setups/vscode.sh" $directory silence
        $login -- /bin/zsh vscode.sh
        rm $directory/vscode.sh

        clear
        
    else 
        echo -e ${Y}"\nThik hai bhai, skip kar diya..\n" ${W}
        sleep 1

    fi
    clear 
}

# Startup script 
fixes() {
    [[ -f $PREFIX/bin/ubuntu ]] && rm $PREFIX/bin/ubuntu
    echo "pulseaudio --start --load='module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1' --exit-idle-time=-1" >> $PREFIX/bin/ubuntu 
    if [[ -z $username ]]; then
        echo "proot-distro login ubuntu-lts --shared-tmp" >> $PREFIX/bin/ubuntu 
    else
        echo "proot-distro login ubuntu-lts --shared-tmp --user $username" >> $PREFIX/bin/ubuntu
    fi
    chmod +x $PREFIX/bin/ubuntu
    
    #  .zshrc me save
    [[ ! -f "$directory/.zshrc" ]] && touch "$directory/.zshrc"
    echo "export PULSE_SERVER=127.0.0.1" >> $directory/.zshrc
}

finish () {
    clear
    sleep 2
    echo ${G}"Badhai ho! Installation Complete ho gayi hai"
    echo ""
    echo ${C}"Desk start Karne Ke Liye Github Pe Process Bataya Gaya Hai"
  
}

main () {
    setup_zsh
    requirements
    choose_desktop
    configures
    user
    install_desktop
    fixes
    finish
}

main
