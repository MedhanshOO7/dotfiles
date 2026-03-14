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
