#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# update.sh — Arch system updater (CLI + GUI)
#
# Install:
#   chmod +x ~/.local/bin/update.sh
#
# Add to ~/.zshrc / ~/.bashrc:
#
# Never source this file — run it directly.
# ═══════════════════════════════════════════════════════════════

# ── Configuration (override in ~/.config/update.conf) ──────────
UPDATE_COUNTRY="${UPDATE_COUNTRY:-India}"
UPDATE_CONFIRM="${UPDATE_CONFIRM:-0}"          # 0 = --noconfirm
UPDATE_AUR_TOOL="${UPDATE_AUR_TOOL:-yay}"
UPDATE_SNAPSHOT="${UPDATE_SNAPSHOT:-0}"        # 1 = attempt snapper/timeshift
UPDATE_NPM="${UPDATE_NPM:-1}"
UPDATE_PIP="${UPDATE_PIP:-0}"                  # NEW: 1 = pip list --outdated upgrade
UPDATE_CARGO="${UPDATE_CARGO:-0}"             # NEW: 1 = cargo install-update -a
UPDATE_LOG="${UPDATE_LOG:-1}"                  # NEW: 1 = write log to file
UPDATE_LOG_DIR="${UPDATE_LOG_DIR:-$HOME/.local/share/update-logs}"
UPDATE_DRY_RUN="${UPDATE_DRY_RUN:-0}"         # NEW: 1 = print steps, run nothing
UPDATE_NOTIFY="${UPDATE_NOTIFY:-1}"           # 1 = desktop notifications in all modes

[[ -f ~/.config/update.conf ]] && source ~/.config/update.conf

# ── Icons ───────────────────────────────────────────────────────
readonly _U_ICON_INFO="software-update-available"
readonly _U_ICON_OK="emblem-default"
readonly _U_ICON_ERR="dialog-error"
readonly _U_ICON_WARN="dialog-warning"

# ── Runtime state ───────────────────────────────────────────────
_U_MODE="cli"
_U_STEP=0
_U_TOTAL=0
_U_FIFO=""
_U_ZENITY_PID=""
_U_FAILED_OPTIONAL=()
_U_GUI_FD_OPEN=0
_U_SUDO_BG_PID=""
_U_LOG_FILE=""           # NEW: active log path for this run

# ═══════════════════════════════════════════════════════════════
# Logging — mode-aware (terminal + notify-send + zenity + file)
# ═══════════════════════════════════════════════════════════════

_u_log() {
    local severity="$1"   # info | warn | ok | err
    local critical="$2"
    local title="$3"
    local body="$4"

    local urgency icon timeout emoji

    case "$severity" in
        info) urgency="low";      icon="$_U_ICON_INFO"; timeout=2000; emoji="→" ;;
        warn) urgency="normal";   icon="$_U_ICON_WARN"; timeout=5000; emoji="⚠" ;;
        ok)   urgency="low";      icon="$_U_ICON_OK";   timeout=2000; emoji="✓" ;;
        err)  urgency="critical"; icon="$_U_ICON_ERR";  timeout=0;    emoji="✗" ;;
    esac

    # ── Terminal output ──────────────────────────────────────
    local line
    case "$severity" in
        info) line="  → $title: $body" ;;
        warn) line="  ⚠ $title: $body" ;;
        ok)   line="  ✓ $title: $body" ;;
        err)  line="  ✗ $title: $body" ;;
    esac

    if [[ "$severity" == "warn" || "$severity" == "err" ]]; then
        echo "$line" >&2
    else
        echo "$line"
    fi

    # ── File log ────────────────────────────────────────────
    if [[ "$UPDATE_LOG" == "1" && -n "$_U_LOG_FILE" ]]; then
        printf '[%s] [%-4s] %s: %s\n' \
            "$(date '+%H:%M:%S')" "${severity^^}" "$title" "$body" \
            >> "$_U_LOG_FILE"
    fi

    # ── Desktop notification (cli + gui) ────────────────────
    # Fires in all modes when UPDATE_NOTIFY=1 and notify-send is available.
    # In gui mode, only step completions (ok/warn/err) are notified to avoid
    # flooding — the zenity bar already covers live "..." progress updates.
    # In cli mode, all severities are notified so the user gets real-time
    # feedback even without a progress window.
    if [[ "$UPDATE_NOTIFY" == "1" ]] && command -v notify-send &>/dev/null; then
        local _do_notify=0
        if [[ "$_U_MODE" == "cli" ]]; then
            _do_notify=1
        elif [[ "$_U_MODE" == "gui" && "$severity" != "info" ]]; then
            # gui: skip the "..." info pings — zenity bar already shows those
            _do_notify=1
        fi

        if [[ "$_do_notify" == "1" ]]; then
            notify-send \
                -u "$urgency" \
                -i "$icon" \
                -a "System Update" \
                -t "$timeout" \
                "$title" \
                "<b>$emoji $body</b>"
        fi
    fi

    # ── Zenity progress bar ──────────────────────────────────
    if [[ "$_U_MODE" == "gui" && "$_U_GUI_FD_OPEN" == "1" && "$_U_TOTAL" -gt 0 ]]; then
        local pct=$(( _U_STEP * 100 / _U_TOTAL ))
        (( pct > 99 )) && pct=99
        printf '%s\n# %s\n' "$pct" "$title: $body" >&4
    fi
}

# ═══════════════════════════════════════════════════════════════
# Step runner
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

    if [[ "$UPDATE_DRY_RUN" == "1" ]]; then
        _u_log info "$critical" "[DRY-RUN] $title" "would run: $*"
        return 0
    fi

    _u_log info "$critical" "$title" "..."

    if "$@"; then
        _u_log ok "$critical" "$title" "$body_ok"
        return 0
    else
        local rc=$?
        if [[ "$critical" == "1" ]]; then
            _u_log err 1 "$title" "$body_fail (exit $rc)"
            _u_cleanup
            return 1
        else
            _u_log warn 0 "$title" "$body_fail — continuing."
            _U_FAILED_OPTIONAL+=("$title")
            return 0
        fi
    fi
}

# ═══════════════════════════════════════════════════════════════
# Hooks (user-overridable in ~/.config/update.conf)
# ═══════════════════════════════════════════════════════════════

update_pre_hook()  { :; }

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

    if ! sudo make -C "$repo_dir" install; then
        echo "  ✗ Linuwu-Sense: make install failed" >&2
        return 3
    fi
}

# ═══════════════════════════════════════════════════════════════
# Snapshot helper
# ═══════════════════════════════════════════════════════════════

_u_snapshot() {
    [[ "$UPDATE_SNAPSHOT" != "1" ]] && return 0

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
}

# ═══════════════════════════════════════════════════════════════
# Auth — single point for both modes
# ═══════════════════════════════════════════════════════════════

_u_auth() {
    if [[ "$UPDATE_DRY_RUN" == "1" ]]; then
        _u_log info 0 "Auth" "Dry-run: skipping authentication."
        return 0
    fi

    if [[ "$_U_MODE" == "gui" ]]; then
        local pass
        pass=$(zenity --password --title="System Update — Authentication" --width=340 2>/dev/null)
        [[ $? -ne 0 || -z "$pass" ]] && {
            _u_log warn 0 "Cancelled" "No password provided."
            return 1
        }

        if ! echo "$pass" | sudo -S true 2>/dev/null; then
            zenity --error --title="Authentication Failed" \
                --text="Incorrect password. Update aborted." --width=320 2>/dev/null
            _u_log err 1 "Auth" "Incorrect password."
            unset pass
            return 1
        fi
        unset pass
    else
        sudo -v || { echo "Authentication failed."; return 1; }
    fi

    _u_sudo_keepalive_start
}

# ── sudo keepalive ───────────────────────────────────────────────

_u_sudo_keepalive_start() {
    ( while true; do sudo -n -v 2>/dev/null; sleep 60; done ) &
    _U_SUDO_BG_PID=$!
}

_u_sudo_keepalive_stop() {
    if [[ -n "${_U_SUDO_BG_PID:-}" ]]; then
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

    exec 4>"$_U_FIFO"
    _U_GUI_FD_OPEN=1

    zenity --progress \
        --title="System Update" \
        --text="Initializing..." \
        --percentage=0 \
        --width=480 \
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
    [[ -n "$_U_LOG_FILE" ]] && summary+=$"\n\nLog saved to:\n$_U_LOG_FILE"

    zenity --info \
        --title="System Update" \
        --text="<b>Done!</b>\n\n$summary" \
        --width=360 2>/dev/null
}

_u_cleanup() {
    _u_sudo_keepalive_stop

    if [[ "$_U_MODE" == "gui" && "$_U_GUI_FD_OPEN" == "1" ]]; then
        printf '100\n# Update failed.\n' >&4 2>/dev/null
        exec 4>&-
        _U_GUI_FD_OPEN=0
        rm -f "$_U_FIFO"
        wait "$_U_ZENITY_PID" 2>/dev/null
        zenity --error \
            --title="Update Failed" \
            --text="A critical step failed. Check your terminal for details." \
            --width=340 2>/dev/null
    fi
}

# ═══════════════════════════════════════════════════════════════
# Log file initialisation
# ═══════════════════════════════════════════════════════════════

_u_log_init() {
    [[ "$UPDATE_LOG" != "1" ]] && return 0
    mkdir -p "$UPDATE_LOG_DIR" || {
        echo "  ⚠ Could not create log dir $UPDATE_LOG_DIR — logging disabled." >&2
        UPDATE_LOG=0
        return 0
    }
    _U_LOG_FILE="$UPDATE_LOG_DIR/update-$(date '+%Y-%m-%d_%H-%M-%S').log"
    printf '# update.sh log — %s\n# mode=%s dry-run=%s\n\n' \
        "$(date)" "$_U_MODE" "$UPDATE_DRY_RUN" > "$_U_LOG_FILE"
}

# ═══════════════════════════════════════════════════════════════
# Step counting — centralised so _U_TOTAL is always accurate
# ═══════════════════════════════════════════════════════════════

_u_count_steps() {
    _U_TOTAL=3

    [[ "$UPDATE_SNAPSHOT" == "1" ]] && (( _U_TOTAL++ ))

    command -v reflector &>/dev/null && (( _U_TOTAL++ ))

    if command -v "$UPDATE_AUR_TOOL" &>/dev/null; then
        (( _U_TOTAL += 3 ))
    fi

    [[ "$UPDATE_NPM" == "1" ]]   && command -v npm   &>/dev/null && (( _U_TOTAL++ ))
    [[ "$UPDATE_PIP" == "1" ]]   && command -v pip   &>/dev/null && (( _U_TOTAL++ ))
    [[ "$UPDATE_CARGO" == "1" ]] && command -v cargo &>/dev/null && (( _U_TOTAL++ ))

    (( _U_TOTAL++ ))   # post-hook
}

# ═══════════════════════════════════════════════════════════════
# Core update logic
# ═══════════════════════════════════════════════════════════════

_u_core() {
    local pacman_flags=( -S )
    local syu_flags=( -Syu )
    if [[ "$UPDATE_CONFIRM" != "1" ]]; then
        pacman_flags+=( --noconfirm )
        syu_flags+=( --noconfirm )
    fi

    _u_count_steps
    _u_log_init

    [[ "$UPDATE_DRY_RUN" == "1" ]] && \
        _u_log info 0 "Dry-run" "No changes will be made. Steps planned: $_U_TOTAL"

    # ── Pre-hook ─────────────────────────────────────────────
    update_pre_hook

    # ── Snapshot ─────────────────────────────────────────────
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
            _u_log warn 0 "Mirrors" \
                "Proceeding with potentially stale mirrors — update may be slower or fetch older packages."
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
            _u_log warn 0 "AUR" \
                "Partial AUR failure can cause library mismatches. Run '${UPDATE_AUR_TOOL} -Sua' manually."
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

    # ── pip [NON-CRITICAL] ───────────────────────────────────
    if [[ "$UPDATE_PIP" == "1" ]] && command -v pip &>/dev/null; then
        _u_step 0 "pip globals" "Outdated global packages upgraded" "pip upgrade failed" -- \
            bash -c 'pip list --outdated --format=freeze 2>/dev/null \
                | cut -d= -f1 \
                | xargs -r pip install --upgrade 2>&1'
    fi

    # ── cargo [NON-CRITICAL] ─────────────────────────────────
    if [[ "$UPDATE_CARGO" == "1" ]] && command -v cargo &>/dev/null; then
        if cargo install-update --version &>/dev/null 2>&1; then
            _u_step 0 "cargo crates" "Installed crates updated" \
                "cargo install-update -a failed" -- \
                cargo install-update -a
        else
            _u_log warn 0 "cargo" \
                "cargo-update not installed. Run: cargo install cargo-update"
        fi
    fi

    # ── Post-hook [NON-CRITICAL] ─────────────────────────────
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
        _u_log ok 0 "Update complete" "All steps succeeded."
    fi

    [[ -n "$_U_LOG_FILE" ]] && \
        _u_log info 0 "Log" "Saved to $_U_LOG_FILE"

    _u_sudo_keepalive_stop
}

# ═══════════════════════════════════════════════════════════════
# Entry point — dispatch only; never sourced
# ═══════════════════════════════════════════════════════════════

_u_usage() {
    cat >&2 <<'EOF'
Usage: update.sh <command>

Commands:
  cli   Run the full update in the terminal
  gui   Run the full update with a Zenity progress window
  dry   Dry-run: print every planned step without executing anything

Alias suggestions for ~/.zshrc or ~/.bashrc:
  alias update='~/.local/bin/update.sh cli'
  alias updateG='~/.local/bin/update.sh gui'
  alias update-dry='~/.local/bin/update.sh dry'

Configuration (~/.config/update.conf):
  UPDATE_NOTIFY=1   # 1 = desktop notifications in all modes (default)
                    # 0 = disable all notify-send calls
EOF
}

main() {
    local cmd="${1:-}"

    case "$cmd" in
        cli)
            _U_MODE="cli"
            _U_STEP=0
            _U_FAILED_OPTIONAL=()
            _U_GUI_FD_OPEN=0
            _U_LOG_FILE=""

            echo "=== System Update ==="
            _u_auth || exit 1
            _u_core
            ;;

        gui)
            _U_MODE="gui"
            _U_STEP=0
            _U_FAILED_OPTIONAL=()
            _U_GUI_FD_OPEN=0
            _U_LOG_FILE=""

            _u_auth      || exit 1
            _u_gui_start
            if _u_core; then
                _u_gui_finish
            fi
            ;;

        dry)
            UPDATE_DRY_RUN=1
            _U_MODE="cli"
            _U_STEP=0
            _U_FAILED_OPTIONAL=()
            _U_GUI_FD_OPEN=0
            _U_LOG_FILE=""

            echo "=== System Update [DRY-RUN — no changes will be made] ==="
            _u_auth || exit 1
            _u_core
            ;;

        ""|--help|-h)
            _u_usage
            exit 0
            ;;

        *)
            echo "update.sh: unknown command '$cmd'" >&2
            _u_usage
            exit 1
            ;;
    esac
}

main "$@"
