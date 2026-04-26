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

    # ── Terminal output (unchanged behavior)
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

    # ── Zenity progress (unchanged)
    if [[ "$_U_MODE" == "gui" && -n "$_U_FIFO" && "$_U_TOTAL" -gt 0 ]]; then
        local pct=$(( _U_STEP * 100 / _U_TOTAL ))
        (( pct > 99 )) && pct=99
        printf '%s\n# %s\n' "$pct" "$title: $body" > "$_U_FIFO"
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
    # consume "--"
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
            return 0   # non-critical: don't abort
        fi
    fi
}

# ═══════════════════════════════════════════════════════════════
# Hooks (pre/post — user-overridable)
# ═══════════════════════════════════════════════════════════════

update_pre_hook()  { :; }   # override in ~/.config/update.conf

update_post_hook() {
    local repo_dir="$HOME/.local/src/Linuwu-Sense"

    echo "  → Linuwu-Sense: Sync + install"

    if [[ -d "$repo_dir/.git" ]]; then
        git -C "$repo_dir" pull || return 1
    else
        git clone https://github.com/0x7375646F/Linuwu-Sense.git "$repo_dir" || return 1
    fi

    make -C "$repo_dir" install || return 1
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
        # validate + cache — never store the variable beyond this scope
        if ! echo "$pass" | sudo -S -v 2>/dev/null; then
            zenity --error --title="Authentication Failed" \
                --text="Incorrect password. Update aborted." --width=320 2>/dev/null
            _u_log err 1 "Auth failed" "Incorrect password."
            return 1
        fi
        unset pass
    else
        # CLI: just refresh ticket, prompt natively if needed
        sudo -v || { echo "Authentication failed."; return 1; }
    fi
}

# ═══════════════════════════════════════════════════════════════
# GUI scaffolding
# ═══════════════════════════════════════════════════════════════

_u_gui_start() {
    _U_FIFO=$(mktemp -u /tmp/update_progress.XXXXXX)
    mkfifo "$_U_FIFO"

    zenity --progress \
        --title="System Update" \
        --text="Initializing..." \
        --percentage=0 \
        --width=480 \
        --pulsate \
        --auto-close \
        --no-cancel < "$_U_FIFO" 2>/dev/null &
    _U_ZENITY_PID=$!

    # Keep fifo open (prevents EOF closing zenity prematurely)
    exec 4>"$_U_FIFO"
}

_u_gui_finish() {
    printf '100\n# Done!\n' >&4
    exec 4>&-
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
    # Called on critical failure — close GUI gracefully
    if [[ "$_U_MODE" == "gui" && -n "$_U_ZENITY_PID" ]]; then
        printf '100\n# Update failed.\n' >&4 2>/dev/null
        exec 4>&- 2>/dev/null
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
    local pacman_flags=( -S --noconfirm )
    local syu_flags=( -Syu )
    [[ "$UPDATE_CONFIRM" == "1" ]] && {
        pacman_flags=( -S )
        syu_flags=( -Syu )
    } || {
        pacman_flags+=()
        syu_flags+=( --noconfirm )
    }

    # Count total steps for progress (static analysis)
    _U_TOTAL=3   # keyring + pacman + summary always run
    command -v reflector        &>/dev/null && (( _U_TOTAL++ ))
    command -v "$UPDATE_AUR_TOOL" &>/dev/null && (( _U_TOTAL += 3 ))  # upgrade + orphans + cache
    [[ "$UPDATE_NPM" == "1" ]] && command -v npm &>/dev/null && (( _U_TOTAL++ ))
    [[ "$UPDATE_SNAPSHOT" == "1" ]] && (( _U_TOTAL++ ))

    # ── Pre-hook & snapshot ──────────────────────────────────
    update_pre_hook
    _u_snapshot

    # ── Keyring [CRITICAL] ───────────────────────────────────
    _u_step 1 "Keyring" "Updated" "pacman -S archlinux-keyring failed" -- \
        sudo pacman "${pacman_flags[@]}" archlinux-keyring \
        || return 1

    # ── Mirrors [NON-CRITICAL but loud on failure] ───────────
    if command -v reflector &>/dev/null; then
        _u_step 0 "Mirrors" "Updated via reflector" \
            "reflector failed — update quality may be reduced" -- \
            sudo reflector \
                --country "$UPDATE_COUNTRY" \
                --latest 20 --fastest 5 --sort rate \
                --save /etc/pacman.d/mirrorlist
        # loud extra warning if mirrors failed
        if [[ " ${_U_FAILED_OPTIONAL[*]} " == *"Mirrors"* ]]; then
            _u_log warn 0 "Mirrors" "Proceeding with potentially stale mirrors — update may be slower or fetch older packages."
        fi
    fi

    # ── Pacman [CRITICAL] ────────────────────────────────────
    _u_step 1 "System upgrade" "pacman -Syu complete" "pacman -Syu failed" -- \
        sudo pacman "${syu_flags[@]}" \
        || return 1

    # ── AUR [NON-CRITICAL but warn loudly] ──────────────────
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

    # ── Post-hook ────────────────────────────────────────────
    update_post_hook

    # ── Summary ──────────────────────────────────────────────
    (( _U_STEP++ ))
    if [[ ${#_U_FAILED_OPTIONAL[@]} -gt 0 ]]; then
        _u_log warn 0 "Update complete" \
            "Non-critical failures: ${_U_FAILED_OPTIONAL[*]}"
    else
        _u_log ok 0 "System fully updated" "All steps succeeded."
    fi
}

# ═══════════════════════════════════════════════════════════════
# Public commands
# ═══════════════════════════════════════════════════════════════

update() {
    _U_MODE="cli"
    _U_STEP=0
    _U_FAILED_OPTIONAL=()

    echo "=== System Update ==="
    _u_auth || return 1
    _u_core
}

updateG() {
    _U_MODE="gui"
    _U_STEP=0
    _U_FAILED_OPTIONAL=()

    _u_auth  || return 1
    _u_gui_start
    _u_core
    _u_gui_finish
}
