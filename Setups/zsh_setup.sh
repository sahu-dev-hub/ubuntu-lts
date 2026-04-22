#!/data/data/com.termux/files/usr/bin/bash

# Colours
G="$(printf '\033[1;32m')"
Y="$(printf '\033[1;33m')"
W="$(printf '\033[1;37m')"
C="$(printf '\033[1;36m')"

echo ${G}"ZSH aur Oh My Zsh setup shuru ho raha hai..."${W}

# 1. ZSH aur dependencies install karna
pkg update && pkg upgrade -y
pkg install zsh git wget ncurses-utils -y

# 2. Oh My Zsh install karna (Non-interactive mode me)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo ${C}"Oh My Zsh download ho raha hai..."${W}
    sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# 3. Plugins install karna (Syntax Highlighting aur Autosuggestions)
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
fi

# 4. .zshrc configure karna
sed -i 's/plugins=(git)/plugins=(git zsh-syntax-highlighting zsh-autosuggestions)/' ~/.zshrc

# 5. Default shell badalna
echo ${Y}"ZSH ko default shell banaya ja raha hai..."${W}
chsh -s zsh

# 6. Termux restart message
clear
echo ${G}"Setup complete ho gaya hai!"${W}
echo ${C}"Ab Termux ko exit karke dubara open karo, ya 'zsh' type karo."${W}