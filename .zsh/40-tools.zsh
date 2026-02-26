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
