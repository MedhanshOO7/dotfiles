# External tools go here (direnv, pyenv, etc.)
mkcd() {
    command mkdir "$1" && cd "$1"
}

+c() {
    command git add -u && git commit -m "$@"
}
search() {
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

# ── Shared helpers ────────────────────────────────────────────────────────────

_update_notify() {
    local urgency="$1" icon="$2" title="$3" body="$4"
    notify-send -u "$urgency" -i "$icon" -a "System Update" "$title" "$body"
}

_update_run() {
    local ICON_INFO="software-update-available"
    local ICON_OK="emblem-default"
    local ICON_ERR="dialog-error"
    local ICON_WARN="dialog-warning"
    local USE_GUI="$1"   # "1" = GUI mode, "0" = terminal mode

    _log() {
        local lvl="$1" icon="$2" title="$3" body="$4"
        [[ "$USE_GUI" == "1" ]] && _update_notify "$lvl" "$icon" "$title" "$body"
        echo "[$title] $body"
    }

    _die() {
        _log critical "$ICON_ERR" "Update failed" "$1"
        return 1
    }

    # ── Keyring ───────────────────────────────────────────────
    _log low "$ICON_INFO" "Updating keyring" "Refreshing archlinux-keyring..."
    sudo pacman -S --noconfirm archlinux-keyring || { _die "Keyring update failed."; return 1; }
    _log normal "$ICON_OK" "Keyring updated" ""

    # ── Mirrors ───────────────────────────────────────────────
    if command -v reflector &>/dev/null; then
        _log low "$ICON_INFO" "Updating mirrors" "Finding fastest mirrors in India..."
        sudo reflector --country India --latest 20 --fastest 5 --sort rate \
            --save /etc/pacman.d/mirrorlist || \
            _log normal "$ICON_WARN" "Reflector failed" "Continuing with existing mirrors."
    else
        _log low "$ICON_WARN" "Skipping mirrors" "reflector not installed."
    fi

    # ── Pacman ────────────────────────────────────────────────
    _log low "$ICON_INFO" "Upgrading packages" "Running pacman -Syu..."
    sudo pacman -Syu --noconfirm || { _die "pacman upgrade failed."; return 1; }
    _log normal "$ICON_OK" "Pacman upgrade done" ""

    # ── AUR (yay) ─────────────────────────────────────────────
    if command -v yay &>/dev/null; then
        _log low "$ICON_INFO" "Upgrading AUR" "Running yay -Sua..."
        yay -Sua --noconfirm || { _die "yay AUR upgrade failed."; return 1; }
        _log normal "$ICON_OK" "AUR upgrade done" ""

        _log low "$ICON_INFO" "Removing orphans" "Cleaning unused dependencies..."
        yay -Yc --noconfirm

        _log low "$ICON_INFO" "Cleaning cache" "Freeing up disk space..."
        yay -Sc --noconfirm
    else
        _log low "$ICON_WARN" "Skipping AUR" "yay not found."
    fi

    # ── npm ───────────────────────────────────────────────────
    if command -v npm &>/dev/null; then
        _log low "$ICON_INFO" "Updating npm" "Upgrading global packages..."
        sudo npm update -g || { _die "npm global update failed."; return 1; }
        _log normal "$ICON_OK" "npm update done" ""
    else
        _log low "$ICON_WARN" "Skipping npm" "npm not found."
    fi

    _log normal "$ICON_OK" "System fully updated" "All packages are up to date."
}

# ── Public commands ───────────────────────────────────────────────────────────

update() {
    echo "Starting system update..."
    sudo -v || { echo "Authentication failed."; return 1; }
    _update_run 0
}

updateG() {
    local PASS
    PASS=$(zenity --password --title="System Update — Authentication" --width=340 2>/dev/null)
    [[ $? -ne 0 || -z "$PASS" ]] && {
        notify-send -u normal -i "dialog-warning" "System Update" "Update cancelled — no password provided."
        return 1
    }

    echo "$PASS" | sudo -S -v 2>/dev/null || {
        zenity --error --title="Authentication failed" \
            --text="Incorrect password. Update cancelled." --width=320 2>/dev/null
        notify-send -u critical -i "dialog-error" "System Update" "Authentication failed — update aborted."
        return 1
    }

    local TOTAL=7
    local STEP=0

    {
        _update_run 1 2>&1 | while IFS= read -r line; do
            (( STEP++ ))
            echo $(( STEP * 100 / TOTAL ))
            echo "# $line"
        done
        echo "100"
        echo "# Done!"
    } | zenity --progress \
        --title="System Update" \
        --text="Starting..." \
        --percentage=0 \
        --width=460 \
        --auto-close \
        --no-cancel 2>/dev/null

    zenity --info \
        --title="System Update" \
        --text="<b>System fully updated!</b>\n\nAll packages, AUR, and npm globals are up to date." \
        --width=340 2>/dev/null &
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
