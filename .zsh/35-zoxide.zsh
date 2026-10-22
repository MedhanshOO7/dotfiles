# zoxide: smarter cd
eval "$(zoxide init zsh)"

# ==========================================
# Directory aliases
# ==========================================
typeset -A CD_DIRS=(
    dbms "$HOME/Downloads/Sem - III/Semester - III/Database Systems"
    dsa "$HOME/Downloads/Sem - III/Semester - III/Data Structures"
    web "$HOME/Downloads/Sem - III/Semester - III/Web Technologies"
)

# ==========================================
# cd → aliases first, zoxide fallback
# ==========================================

cd() {
    local target="${CD_DIRS[$1]}"

    if [[ -n "$target" ]]; then
        builtin cd "$target"
    else
        z "$@"
    fi
}

