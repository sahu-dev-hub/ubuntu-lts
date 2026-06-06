#!/data/data/com.termux/files/usr/bin/bash

# =====================================================
#   Ubuntu 24.04 LTS Installer for Termux
#   proot-distro v4 aur v5 dono ke saath kaam karta hai
#   v4 → ubuntu-lts.sh plugin use karta hai
#   v5 → ubuntu:24.04 Docker image + --name flag
#   Author: sahu-dev-hub
# =====================================================

PD=$PREFIX/var/lib/proot-distro/installed-rootfs
ds_name=ubuntu-lts

clear

# Colours
R="$(printf '\033[1;31m')"
G="$(printf '\033[1;32m')"
Y="$(printf '\033[1;33m')"
W="$(printf '\033[1;37m')"
C="$(printf '\033[1;36m')"

# ── Version detect karo ──────────────────────────────
detect_pd_version() {
    local ver
    ver=$(proot-distro --version 2>/dev/null | grep -oP '\d+' | head -1)
    echo "${ver:-4}"
}

PD_VER=$(detect_pd_version)
echo "${C}proot-distro version detected: v${PD_VER}${W}"
sleep 1

# ── proot-distro install command (v4 vs v5) ──────────
install_ubuntu() {
    if [[ "$PD_VER" -ge 5 ]]; then
        # v5: Docker Hub se ubuntu:24.04, custom naam ubuntu-lts
        echo "${G}[v5] ubuntu:24.04 Docker image se install ho raha hai...${W}"
        proot-distro install ubuntu:24.04 --name "$ds_name"
    else
        # v4: plugin .sh file based method
        echo "${G}[v4] Plugin file (ubuntu-lts.sh) se install ho raha hai...${W}"
        if [[ ! -f "$PREFIX/etc/proot-distro/$ds_name.sh" ]]; then
            echo "${Y}Plugin file download ho rahi hai...${W}"
            wget -q --show-progress \
                "https://raw.githubusercontent.com/sahu-dev-hub/ubuntu-lts/refs/heads/main/ubuntu-lts.sh" \
                -O "$PREFIX/etc/proot-distro/$ds_name.sh"
        fi
        proot-distro install "$ds_name"
    fi
}

# ── remove command (v4 vs v5) ────────────────────────
remove_ubuntu() {
    proot-distro remove "$ds_name" 2>/dev/null || true
    # Agar directory manually reh gayi ho
    [[ -d "$PD/$ds_name" ]] && rm -rf "$PD/$ds_name"
    # v4 plugin file bhi hata do (v5 mein exist nahi karti, koi fark nahi)
    [[ -f "$PREFIX/etc/proot-distro/$ds_name.sh" ]] && rm -f "$PREFIX/etc/proot-distro/$ds_name.sh"
}

## ask() - Y/N prompt
ask() {
    local msg=$*
    echo -ne "$msg\t[y/n]: "
    read -r choice
    case $choice in
        y|Y|yes|YES) return 0 ;;
        n|N|no|NO)   return 1 ;;
        "")          return 0 ;;
        *)           return 1 ;;
    esac
}

## download_script()
download_script() {
    local url=$1
    local dir=$2
    local mode=$3
    local script
    script=$(echo "$url" | awk -F/ '{print $NF}')
    case $mode in
        verbose) WGET="wget --show-progress" ;;
        silence) WGET="wget -q --show-progress" ;;
        *)       WGET="wget" ;;
    esac
    $WGET "$url" -P "$dir"
}

# ── Step 1: ZSH setup ────────────────────────────────
setup_zsh() {
    echo "${G}Step 1: ZSH install aur setup ho raha hai, thoda wait karo...${W}"
    download_script \
        "https://raw.githubusercontent.com/sahu-dev-hub/ubuntu-lts/refs/heads/main/Setups/zsh_setup.sh" \
        "$HOME" silence
    bash "$HOME/zsh_setup.sh"
    rm -f "$HOME/zsh_setup.sh"
    sleep 1
}

# ── Step 2: Requirements ─────────────────────────────
requirements() {
    echo "${G}Ye script proot-distro mein Ubuntu 24.04 LTS install karegi${W}"
    echo "${C}Detected proot-distro version: v${PD_VER}${W}"
    sleep 1
    echo "${G}Zaroori packages install ho rahe hain...${W}"
    pkg install pulseaudio proot-distro wget -y

    [[ ! -d "$HOME/storage" ]] && {
        echo "${C}Bhai, storage permission allow kar dena${W}"
        termux-setup-storage
    }

    # Agar pehle se install hai toh pooch
    if proot-distro list 2>/dev/null | grep -q "$ds_name" || [[ -d "$PD/$ds_name" ]]; then
        if ask "${Y}Pehle se Ubuntu install hai, kya ise delete karke naya install karein?${W}"; then
            echo ""
            echo "${Y}Purani installation hata rahi hai....${W}"
            remove_ubuntu || { echo "${R}Remove nahi ho payi, manually delete karo: rm -rf $PD/$ds_name${W}"; exit 1; }
        else
            echo "${R}Installation cancel kar di gayi hai${W}"
            exit 1
        fi
    fi
}

# ── Step 3: Desktop choose ───────────────────────────
choose_desktop() {
    clear
    echo "${C}Koi Bhi Ek Desktop chuno${Y}"
    echo " 1) XFCE (Light Weight aur Fast)"
    echo " 2) MATE (Classic Look)"
    echo "${C}Desktop chunne ke liye 1-2 enter karo"
    echo "${C}Agar Desktop nahi chahiye toh sirf '${W}CLI${C}' likho${W}"
    read -r desktop
    sleep 1
    case $desktop in
        1|2) echo "${G}Chalo bhai, installation shuru karte hain${Y}" ;;
        CLI) echo "${G}Theek hai, sirf basic Ubuntu install hoga...${Y}" ;;
        *)   echo "${R}Galat option chuna hai"; sleep 1; choose_desktop ;;
    esac
}

# ── Step 4: Ubuntu install + basic setup ─────────────
configures() {
    echo "${G}Ubuntu 24.04 LTS install ho rahi hai...${W}"
    install_ubuntu

    echo "${G}Ubuntu ke andar zaroori packages install ho rahi hain...${W}"
    # Temp .bashrc se initial setup karwao
    cat > "$PD/$ds_name/root/.bashrc" <<- 'EOF'
        export DEBIAN_FRONTEND=noninteractive
        apt-get update -y
        apt-get upgrade -y
        apt-get install -y sudo nano wget openssl git zsh
        exit
EOF
    proot-distro login "$ds_name"
    rm -f "$PD/$ds_name/root/.bashrc"
}

# ── Step 5: User banana ──────────────────────────────
user() {
    clear
    if ask "${C}Kya aap apna naya user banana chahte hain?${W}"; then
        echo ""
        echo "${C}Username type karein (lowercase me): ${W}"
        read -r username
        directory="$PD/$ds_name/home/$username"
        login="proot-distro login $ds_name --user $username"
        echo ""
        sleep 1
        echo "${G}ZSH shell ke saath naya user ban raha hai ....${W}"
        cat > "$PD/$ds_name/root/.bashrc" <<- EOF
            useradd -m \
                -G sudo \
                -d /home/${username} \
                -k /etc/skel \
                -s /bin/zsh \
                ${username}
            echo "${username} ALL=(root) ALL" > /etc/sudoers.d/${username}
            chmod 0440 /etc/sudoers.d/${username}
            echo "${username} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
            exit
EOF
        proot-distro login "$ds_name"
        rm -f "$PD/$ds_name/root/.bashrc"
        sleep 2
        [[ ! -d "$directory" ]] && {
            echo -e "${R}User nahi ban paya\nAb root user se hi kaam chalana padega${W}"
            directory="$PD/$ds_name/root"
            login="proot-distro login $ds_name"
            username=""
        }
    else
        echo ""
        echo "${G}Installation root user se hi complete hogi${W}"
        sleep 2
        directory="$PD/$ds_name/root"
        login="proot-distro login $ds_name"
        username=""
    fi
}

# ── Step 6: Desktop install ──────────────────────────
install_desktop() {
    local desk=true
    case $desktop in
        1) xfce_mode ;;
        2) mate_mode ;;
        *) echo "${G}Koi Desktop nahi chuna, skipping ....${W}"; desk=false; sleep 2 ;;
    esac
    $desk && apps
}

xfce_mode() {
    echo "${G}XFCE Desktop install ho raha hai...${W}"
    download_script \
        "https://raw.githubusercontent.com/sahu-dev-hub/ubuntu-lts/refs/heads/main/Desktop/xfce.sh" \
        "$directory" silence
    $login -- /bin/zsh xfce.sh
    rm -f "$directory/xfce.sh"
}

mate_mode() {
    echo "${G}Mate Desktop install ho raha hai...${W}"
    download_script \
        "https://raw.githubusercontent.com/sahu-dev-hub/ubuntu-lts/refs/heads/main/Desktop/mate.sh" \
        "$directory" silence
    $login -- /bin/zsh mate.sh
    rm -f "$directory/mate.sh"
}

# ── Step 7: Extra apps ───────────────────────────────
apps() {
    clear
    if ask "${C}Firefox Web Browser install karna hai?${W}"; then
        echo -e "${G}\nFirefox Browser install ho raha hai .... ${W}"
        download_script \
            "https://raw.githubusercontent.com/sahu-dev-hub/ubuntu-lts/refs/heads/main/Setups/firefox.sh" \
            "$directory" silence
        [[ -f "$directory/.zshrc" ]] && mv "$directory/.zshrc" "$directory/.zbak"
        cat > "$directory/.zshrc" <<- 'EOF'
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
user_pref("security.sandbox.content.level", 1);' \
            >> "$directory"/.mozilla/firefox-esr/*default-esr*/prefs.js 2>/dev/null || true
        rm -f "$directory/.zshrc"
        [[ -f "$directory/.zbak" ]] && mv "$directory/.zbak" "$directory/.zshrc"
        clear; sleep 1
    else
        echo -e "${Y}\nThik hai bhai, skip kar diya..\n${W}"; sleep 1
    fi

    if ask "${C}Discord (Webcord) install karna hai?${W}"; then
        echo -e "${G}\nDiscord install ho raha hai .... ${W}"
        download_script \
            "https://raw.githubusercontent.com/sahu-dev-hub/ubuntu-lts/refs/heads/main/Setups/webcord.sh" \
            "$directory" silence
        $login -- /bin/zsh webcord.sh
        rm -f "$directory/webcord.sh"
        clear
    else
        echo -e "${Y}\nThik hai bhai, skip kar diya..\n${W}"; sleep 1
    fi

    if ask "${C}Gimp (Photo editor) install karna hai?${W}"; then
        echo -e "${G}\nGimp install ho raha hai .... ${W}"
        download_script \
            "https://raw.githubusercontent.com/sahu-dev-hub/ubuntu-lts/refs/heads/main/Setups/gimp.sh" \
            "$directory" silence
        $login -- /bin/zsh gimp.sh
        rm -f "$directory/gimp.sh"
        clear
    else
        echo -e "${Y}\nThik hai bhai, skip kar diya..\n${W}"; sleep 1
    fi

    if ask "${C}VScode install karna hai?${W}"; then
        echo -e "${G}\nVScode install ho raha hai .... ${W}"
        download_script \
            "https://raw.githubusercontent.com/sahu-dev-hub/ubuntu-lts/refs/heads/main/Setups/vscode.sh" \
            "$directory" silence
        $login -- /bin/zsh vscode.sh
        rm -f "$directory/vscode.sh"
        clear
    else
        echo -e "${Y}\nThik hai bhai, skip kar diya..\n${W}"; sleep 1
    fi
    clear
}

# ── Step 8: Startup script banana ───────────────────
fixes() {
    rm -f "$PREFIX/bin/ubuntu"
    {
        echo "pulseaudio --start --load='module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1' --exit-idle-time=-1"
        if [[ -z "$username" ]]; then
            echo "proot-distro login $ds_name --shared-tmp"
        else
            echo "proot-distro login $ds_name --shared-tmp --user $username"
        fi
    } > "$PREFIX/bin/ubuntu"
    chmod +x "$PREFIX/bin/ubuntu"

    # .zshrc me PULSE_SERVER save karo
    [[ ! -f "$directory/.zshrc" ]] && touch "$directory/.zshrc"
    grep -qxF "export PULSE_SERVER=127.0.0.1" "$directory/.zshrc" \
        || echo "export PULSE_SERVER=127.0.0.1" >> "$directory/.zshrc"
}

# ── Finish ───────────────────────────────────────────
finish() {
    clear
    sleep 2
    echo "${G}Badhai ho! Ubuntu 24.04 LTS installation complete ho gayi hai!${W}"
    echo ""
    echo "${C}Ubuntu start karne ke liye type karo:${W}"
    echo "    ubuntu"
    echo ""
    echo "${C}Ya directly:${W}"
    echo "    proot-distro login $ds_name"
    echo ""
    echo "${Y}Desktop start karne ka process GitHub pe bataya gaya hai.${W}"
}

# ── Main ─────────────────────────────────────────────
main() {
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
