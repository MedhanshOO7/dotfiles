# External tools go here (direnv, pyenv, etc.)
mkcd(){
    command mkdir "$1" && cd "$1"
} 

+c(){
    command git add -u && git commit -m "$@"
    }
search () {
    brave --new-tab "https://duckduckgo.com/?q=$(printf "%s" "$*" | sed 's/ /+/g')"
}

+S() {
    if pacman -Si "$1" &>/dev/null; then
        echo "Installing $1 from official repos..."
        sudo pacman -S "$1"
    else
        echo "$1 not in official repos, trying AUR via yay..."
        yay -S "$1"
    fi
}
-S(){
    printf 'Uninstalling, %s ...' $1
    sudo pacman -Rns $1
}

-R(){
    printf 'Uninstalling, %s ...' $1
    sudo pacman -Rns $1
}


vman() { 
    man "$@" | vim -c "set ft=man" -; 
}   

help(){
    bash -c "help $@"
}

update() {
    set -e

    echo " Updating keyring..."
    sudo pacman -Sy --noconfirm archlinux-keyring || {
        echo "Keyring update failed"; return 1;
    }

    echo " Updating mirrors..."
    sudo reflector --latest 10 --sort rate --save /etc/pacman.d/mirrorlist || {
        echo "Reflector failed, continuing with existing mirrors..."
    }

    echo " Upgrading system (pacman)..."
    sudo pacman -Syu --noconfirm || {
        echo "Pacman upgrade failed"; return 1;
    }

    echo " Upgrading AUR (yay)..."
    yay -Sua --noconfirm || {
        echo "Yay upgrade failed"; return 1;
    }

    echo " Cleaning cache..."
    yay -Yc --noconfirm

    echo " System fully updated."
}

open_nvim(){
    nvim .
    zle reset-prompt
}
open_config(){
    nvim ~/.zsh
    zle reset-prompt
}
source_config(){
    echo "Sourcing......."
    source ~/.zshrc
    zle reset-prompt
    echo "Sourced again"
}

# Regesting the widgets 
zle -N open_nvim
zle -N open_config
zle -N source_config

# Key binds
bindkey '^g' open_nvim
bindkey '^o' open_config
bindkey '^[.' open_config
bindkey '^[s' source_config


