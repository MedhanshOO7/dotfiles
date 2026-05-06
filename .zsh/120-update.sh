# ═══════════════════════════════════════════════════════════════
# update.sh — Arch system updater (CLI + GUI)
# ═══════════════════════════════════════════════════════════════

# ── Configuration (override in ~/.config/update.conf) ──────────
UPDATE_COUNTRY="${UPDATE_COUNTRY:-India}"
UPDATE_CONFIRM="${UPDATE_CONFIRM:-0}"          # 0 = --noconfirm
UPDATE_AUR_TOOL="${UPDATE_AUR_TOOL:-yay}"
UPDATE_SNAPSHOT="${UPDATE_SNAPSHOT:-0}"        # 1 = attempt snapper
UPDATE_NPM="${UPDATE_NPM:-1}"

[[ -f ~/.config/update.conf ]] && source ~/.config/update.conf

# ── Icons ───────────────────────────────────────────────────────
readonly _U_ICON_INFO="software-update-available"
readonly _U_ICON_OK="emblem-default"
readonly _U_ICON_ERR="dialog-error"
readonly _U_ICON_WARN="dialog-warning"

# ── Runtime state ───────────────────────────────────────────────
_U_MODE="cli"          # cli | gui
_U_STEP=0
_U_TOTAL=0
_U_FIFO=""
_U_ZENITY_PID=""
_U_FAILED_OPTIONAL=()
_U_GUI_FD_OPEN=0       # FIX #6: track whether fd 4 is open
_U_SUDO_BG_PID=""      # FIX #8: background sudo keepalive pid

# ═══════════════════════════════════════════════════════════════
# Core logging — single implementation, mode-aware
# ═══════════════════════════════════════════════════════════════

_u_log() {
    local severity="$1"   # info | warn | ok | err
    local critical="$2"
    local title="$3"
    local body="$4"

    local urgency icon timeout emoji formatted_body

    case "$severity" in
        info)
            urgency="low"
            icon="software-update-available"
            timeout=2000
            emoji="→"
            ;;
        warn)
            urgency="normal"
            icon="dialog-warning"
            timeout=5000
            emoji="⚠"
            ;;
        ok)
            urgency="low"
            icon="software-update-available"
            timeout=2000
            emoji="✓"
            ;;
        err)
            urgency="critical"
            icon="dialog-error"
            timeout=0
            emoji="✗"
            ;;
    esac

    # ── Terminal output
    case "$severity" in
        info) echo "  → $title: $body" ;;
        warn) echo "  ⚠ $title: $body" >&2 ;;
        ok)   echo "  ✓ $title" ;;
        err)  echo "  ✗ $title: $body" >&2 ;;
    esac

    # ── Format body (rich style)
    formatted_body="<b>$emoji $body</b>"

    # ── GUI notification
    if [[ "$_U_MODE" == "gui" ]]; then
        notify-send \
            -u "$urgency" \
            -i "$icon" \
            -a "System Update" \
            -t "$timeout" \
            "$title" \
            "$formatted_body"
    fi

    # ── Zenity progress
    # FIX #6: only write to fd 4 if it was successfully opened
    if [[ "$_U_MODE" == "gui" && "$_U_GUI_FD_OPEN" == "1" && "$_U_TOTAL" -gt 0 ]]; then
        local pct=$(( _U_STEP * 100 / _U_TOTAL ))
        (( pct > 99 )) && pct=99
        printf '%s\n# %s\n' "$pct" "$title: $body" >&4
    fi
}

# ═══════════════════════════════════════════════════════════════
# Step runner — wraps a command with logging + error handling
#
# Usage: _u_step <critical:0|1> <title> <body_ok> <body_fail> -- cmd args...
# ═══════════════════════════════════════════════════════════════

_u_step() {
    local critical="$1"; shift
    local title="$1";    shift
    local body_ok="$1";  shift
    local body_fail="$1"; shift
    [[ "$1" == "--" ]] && shift

    (( _U_STEP++ ))
    _u_log info "$critical" "$title" "..."

    if "$@"; then
        _u_log ok "$critical" "$title" "$body_ok"
        return 0
    else
        local rc=$?
        if [[ "$critical" == "1" ]]; then
            _u_log err 1 "$title failed" "$body_fail (exit $rc)"
            _u_cleanup
            return 1
        else
            _u_log warn 0 "$title failed" "$body_fail — continuing."
            _U_FAILED_OPTIONAL+=("$title")
            return 0
        fi
    fi
}

# ═══════════════════════════════════════════════════════════════
# Hooks (pre/post — user-overridable)
# ═══════════════════════════════════════════════════════════════

update_pre_hook() { :; }   # override in ~/.config/update.conf

# FIX #3: added sudo to make install
# FIX #4: each sub-step returns a distinct non-zero code so callers can tell
#          which phase failed; wrapper in _u_core reports it properly
update_post_hook() {
    local repo_dir="$HOME/.local/src/Linuwu-Sense"

    echo "  → Linuwu-Sense: Sync + install"

    if [[ -d "$repo_dir/.git" ]]; then
        if ! git -C "$repo_dir" pull; then
            echo "  ✗ Linuwu-Sense: git pull failed" >&2
            return 1
        fi
    else
        if ! git clone https://github.com/0x7375646F/Linuwu-Sense.git "$repo_dir"; then
            echo "  ✗ Linuwu-Sense: git clone failed" >&2
            return 2
        fi
    fi

    if ! sudo make -C "$repo_dir" install; then      # FIX #3: sudo added
        echo "  ✗ Linuwu-Sense: make install failed" >&2
        return 3
    fi
}

_u_snapshot() {
    if [[ "$UPDATE_SNAPSHOT" == "1" ]]; then
        if command -v snapper &>/dev/null; then
            _u_step 0 "Snapshot" "Pre-update snapshot created" \
                "snapper failed — continuing without snapshot" -- \
                sudo snapper -c root create --description "pre-update" --cleanup-algorithm number
        elif command -v timeshift &>/dev/null; then
            _u_step 0 "Snapshot" "Timeshift snapshot created" \
                "timeshift failed — continuing without snapshot" -- \
                sudo timeshift --create --comments "pre-update" --scripted
        else
            _u_log warn 0 "Snapshot" "No snapper/timeshift found — skipping."
        fi
    fi
}

# ═══════════════════════════════════════════════════════════════
# Auth — single point, both modes
# ═══════════════════════════════════════════════════════════════

_u_auth() {
    if [[ "$_U_MODE" == "gui" ]]; then
        local pass
        pass=$(zenity --password --title="System Update — Authentication" --width=340 2>/dev/null)
        [[ $? -ne 0 || -z "$pass" ]] && {
            _u_log warn 0 "Cancelled" "No password provided."
            return 1
        }
        if ! echo "$pass" | sudo -S -v 2>/dev/null; then
            zenity --error --title="Authentication Failed" \
                --text="Incorrect password. Update aborted." --width=320 2>/dev/null
            _u_log err 1 "Auth failed" "Incorrect password."
            unset pass
            return 1
        fi
        unset pass
    else
        sudo -v || { echo "Authentication failed."; return 1; }
    fi

    # FIX #8: keep sudo ticket alive in the background for the full run
    _u_sudo_keepalive_start
}

# ── FIX #8: sudo keepalive helpers ──────────────────────────────

_u_sudo_keepalive_start() {
    (
        while true; do
            sudo -n -v 2>/dev/null
            sleep 60
        done
    ) &
    _U_SUDO_BG_PID=$!
}

_u_sudo_keepalive_stop() {
    if [[ -n "$_U_SUDO_BG_PID" ]]; then
        kill "$_U_SUDO_BG_PID" 2>/dev/null
        wait "$_U_SUDO_BG_PID" 2>/dev/null
        _U_SUDO_BG_PID=""
    fi
}

# ═══════════════════════════════════════════════════════════════
# GUI scaffolding
# ═══════════════════════════════════════════════════════════════

_u_gui_start() {
    _U_FIFO=$(mktemp -u /tmp/update_progress.XXXXXX)
    mkfifo "$_U_FIFO"

    # FIX #5: open the write end BEFORE launching zenity so it never sees EOF
    exec 4>"$_U_FIFO"
    _U_GUI_FD_OPEN=1

    zenity --progress \
        --title="System Update" \
        --text="Initializing..." \
        --percentage=0 \
        --width=480 \
        --pulsate \
        --auto-close \
        --no-cancel < "$_U_FIFO" 2>/dev/null &
    _U_ZENITY_PID=$!
}

_u_gui_finish() {
    printf '100\n# Done!\n' >&4
    exec 4>&-
    _U_GUI_FD_OPEN=0
    rm -f "$_U_FIFO"
    wait "$_U_ZENITY_PID" 2>/dev/null

    local summary="System fully updated."
    if [[ ${#_U_FAILED_OPTIONAL[@]} -gt 0 ]]; then
        summary+=$'\n\nNon-critical failures:\n'
        summary+="$(printf '  • %s\n' "${_U_FAILED_OPTIONAL[@]}")"
    fi

    zenity --info \
        --title="System Update" \
        --text="<b>Done!</b>\n\n$summary" \
        --width=360 2>/dev/null &
}

_u_cleanup() {
    _u_sudo_keepalive_stop   # FIX #8

    # FIX #6: only close fd 4 and signal zenity if the GUI fd was actually opened
    if [[ "$_U_MODE" == "gui" && "$_U_GUI_FD_OPEN" == "1" ]]; then
        printf '100\n# Update failed.\n' >&4 2>/dev/null
        exec 4>&-
        _U_GUI_FD_OPEN=0
        rm -f "$_U_FIFO"
        wait "$_U_ZENITY_PID" 2>/dev/null
        zenity --error \
            --title="Update Failed" \
            --text="A critical step failed. Check your terminal for details." \
            --width=340 2>/dev/null &
    fi
}

# ═══════════════════════════════════════════════════════════════
# Core update logic — ONE implementation, used by both commands
# ═══════════════════════════════════════════════════════════════

_u_core() {
    # FIX #1: replaced &&...|| anti-pattern with a proper if/else
    local pacman_flags=( -S )
    local syu_flags=( -Syu )
    if [[ "$UPDATE_CONFIRM" != "1" ]]; then
        pacman_flags+=( --noconfirm )
        syu_flags+=( --noconfirm )
    fi

    # FIX #7: count steps accurately
    # Base steps: keyring + pacman + summary = 3
    _U_TOTAL=3
    [[ "$UPDATE_SNAPSHOT" == "1" ]] && (( _U_TOTAL++ ))
    command -v reflector              &>/dev/null && (( _U_TOTAL++ ))
    if command -v "$UPDATE_AUR_TOOL"  &>/dev/null; then
        (( _U_TOTAL += 3 ))   # upgrade + orphans + cache
    fi
    [[ "$UPDATE_NPM" == "1" ]] && command -v npm &>/dev/null && (( _U_TOTAL++ ))
    (( _U_TOTAL++ ))   # post-hook always runs (counted as one step)

    # ── Pre-hook & snapshot ──────────────────────────────────
    update_pre_hook
    _u_snapshot

    # ── Keyring [CRITICAL] ───────────────────────────────────
    _u_step 1 "Keyring" "Updated" "pacman -S archlinux-keyring failed" -- \
        sudo pacman "${pacman_flags[@]}" archlinux-keyring \
        || return 1

    # ── Mirrors [NON-CRITICAL] ───────────────────────────────
    if command -v reflector &>/dev/null; then
        _u_step 0 "Mirrors" "Updated via reflector" \
            "reflector failed — update quality may be reduced" -- \
            sudo reflector \
                --country "$UPDATE_COUNTRY" \
                --latest 20 --fastest 5 --sort rate \
                --save /etc/pacman.d/mirrorlist

        if [[ " ${_U_FAILED_OPTIONAL[*]} " == *"Mirrors"* ]]; then
            _u_log warn 0 "Mirrors" "Proceeding with potentially stale mirrors — update may be slower or fetch older packages."
        fi
    fi

    # ── Pacman [CRITICAL] ────────────────────────────────────
    _u_step 1 "System upgrade" "pacman -Syu complete" "pacman -Syu failed" -- \
        sudo pacman "${syu_flags[@]}" \
        || return 1

    # ── AUR [NON-CRITICAL] ──────────────────────────────────
    if command -v "$UPDATE_AUR_TOOL" &>/dev/null; then
        _u_step 0 "AUR upgrade" "AUR packages updated" \
            "AUR upgrade failed — system may be partially updated" -- \
            "$UPDATE_AUR_TOOL" -Sua --noconfirm

        if [[ " ${_U_FAILED_OPTIONAL[*]} " == *"AUR upgrade"* ]]; then
            _u_log warn 0 "AUR" "Partial AUR failure on Arch can cause library mismatches. Run '${UPDATE_AUR_TOOL} -Sua' manually to resolve."
        fi

        _u_step 0 "Orphans" "Removed unused dependencies" "Orphan removal failed" -- \
            "$UPDATE_AUR_TOOL" -Yc --noconfirm

        _u_step 0 "Cache" "Package cache cleaned" "Cache clean failed" -- \
            "$UPDATE_AUR_TOOL" -Sc --noconfirm
    fi

    # ── npm [NON-CRITICAL] ───────────────────────────────────
    if [[ "$UPDATE_NPM" == "1" ]] && command -v npm &>/dev/null; then
        _u_step 0 "npm globals" "Global packages updated" "npm update -g failed" -- \
            sudo npm update -g
    fi

    # ── Post-hook [NON-CRITICAL] ─────────────────────────────
    # FIX #2: now wrapped in _u_step so failures are caught and reported
    _u_step 0 "Linuwu-Sense" "Synced and installed" \
        "clone/build failed — check output above" -- \
        update_post_hook

    if [[ " ${_U_FAILED_OPTIONAL[*]} " == *"Linuwu-Sense"* ]]; then
        _u_log warn 0 "Linuwu-Sense" "Run 'update_post_hook' manually to retry."
    fi

    # ── Summary ──────────────────────────────────────────────
    (( _U_STEP++ ))
    if [[ ${#_U_FAILED_OPTIONAL[@]} -gt 0 ]]; then
        _u_log warn 0 "Update complete" \
            "Non-critical failures: ${_U_FAILED_OPTIONAL[*]}"
    else
        _u_log ok 0 "System fully updated" "All steps succeeded."
    fi

    _u_sudo_keepalive_stop   # FIX #8: clean up keepalive on success too
}

# ═══════════════════════════════════════════════════════════════
# Public commands
# ═══════════════════════════════════════════════════════════════

update() {
    _U_MODE="cli"
    _U_STEP=0
    _U_FAILED_OPTIONAL=()
    _U_GUI_FD_OPEN=0

    echo "=== System Update ==="
    _u_auth || return 1
    _u_core
}

updateG() {
    _U_MODE="gui"
    _U_STEP=0
    _U_FAILED_OPTIONAL=()
    _U_GUI_FD_OPEN=0

    _u_auth      || return 1
    _u_gui_start
    _u_core
    _u_gui_finish
}
