# External tools go here (direnv, pyenv, etc.)
mkcd() {
    command mkdir "$1" && cd "$1"
}

unalias ls
ls() {
    local target="${@:-.}"

    eza --color=always --icons --git --sort=name --only-files $target
    echo
    eza --color=always --icons --git --sort=name --only-dirs $target
}

+c() {
    command git add -u && git commit -m "$@"
}
search() {
    brave --new-tab "https://duckduckgo.com/?q=$(printf "%s" "$*" | sed 's/ /+/g')"
}
# UPGRADE SCRIPT
source /home/medhansh/.zsh/120-update.sh
#
+S() {
    if pacman -Si "$1" &>/dev/null; then
        echo "Installing $1 from official repos..."
        sudo pacman -S "$1"
    else
        echo "$1 not in official repos, trying AUR via yay..."
        yay -S "$1"
    fi
}
-S() {
    printf 'Uninstalling, %s ...' $1
    sudo pacman -Rns $1
}

-R() {
    printf 'Uninstalling, %s ...' $1
    sudo pacman -Rns $1
}

vman() {
    man "$@" | vim -c "set ft=man" -
}

help() {
    bash -c "help $@"
}

open_nvim() {
    nvim .
    zle reset-prompt
}
open_config() {
    nvim ~/.zsh
    zle reset-prompt
}

source_config() {
    echo "Sourcing......."
    source ~/.zshrc
    zle reset-prompt
    echo "Sourced again\n"
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
