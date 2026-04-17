# Core environment
export ZSH="$HOME/.oh-my-zsh"
export PATH="$(npm config get prefix)/bin:$PATH"
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'


# man page colors (Catppuccin Frappe)
export LESS_TERMCAP_mb=$'\e[1;31m'
export LESS_TERMCAP_md=$'\e[1;38;5;111m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[48;5;60;38;5;223m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[38;5;150m'
export MANPAGER='nvim +Man!'

# FZF
export FZF_DEFAULT_OPTS=$'
--color=bg:#303446,fg:#c6d0f5,hl:#e78284
--color=bg+:#414559,fg+:#c6d0f5,hl+:#e78284
--color=info:#8caaee,prompt:#a6d189,pointer:#f4b8e4
--color=marker:#ef9f76,spinner:#81c8be,header:#8caaee
--reverse
--margin=1%
--padding=2%
--border=rounded
--preview-window=right:60%:wrap
--preview=\'
# --- enhanced preview (static colors, dynamic content) ---
printf "\033_Ga=d,d=A\033\\\\" 2>/dev/null

PREVIEW_LINES=${FZF_PREVIEW_LINES:-$LINES}
PREVIEW_COLS=${FZF_PREVIEW_COLUMNS:-$COLUMNS}
((PREVIEW_LINES > 0)) || PREVIEW_LINES=24
((PREVIEW_COLS > 0)) || PREVIEW_COLS=80

IMG_HEIGHT=$((PREVIEW_LINES < 30 ? 12 : 18))
META_LINES=6
AVAILABLE=$((PREVIEW_LINES - META_LINES - 1))
((AVAILABLE < 1)) && AVAILABLE=1

DIVIDER=$(printf "%0.s─" $(seq 1 $PREVIEW_COLS))
RESET="\033[0m"
LABEL="\033[38;2;140;170;238m"   # #8caaee
VALUE="\033[38;2;198;208;245m"   # #c6d0f5
ICON="\033[38;2;166;209;137m"    # #a6d189

meta() { echo -e "${ICON}$1${RESET}  ${LABEL}$2${RESET}  ${VALUE}$3${RESET}"; }

# directories
if [ -d "{}" ]; then
  if command -v eza >/dev/null; then
    eza --icons --tree --level=2 --color=always "{}" 2>/dev/null | head -n $AVAILABLE
  else
    ls -la --color=always "{}" 2>/dev/null | head -n $AVAILABLE
  fi
  used=$(eza --tree --level=2 "{}" 2>/dev/null | wc -l)
  ((used < AVAILABLE)) && printf "\n%.0s" $(seq 1 $((AVAILABLE - used)))
  echo "$DIVIDER"
  meta "📁" "name:    " "$(basename "{}")"
  meta "📦" "items:   " "$(find "{}" -maxdepth 1 -type f | wc -l)"
  meta "💾" "size:    " "$(du -sh "{}" 2>/dev/null | cut -f1)"
  meta "🕒" "modified:" "$(date -r "{}" "+%Y-%m-%d %H:%M" 2>/dev/null)"
  exit 0
fi

# file type detection
mime=$(file --mime-type -b "{}" 2>/dev/null)
case "$mime" in
  image/*)
    if [[ -n "$KITTY_WINDOW_ID" ]]; then
      kitty +kitten icat --transfer-mode=memory --stdin no --scale-up \
        --place ${PREVIEW_COLS}x${IMG_HEIGHT}@0x0 "{}" 2>/dev/null
      used=$IMG_HEIGHT
    else
      echo "[Image] $(basename "{}")"
      used=1
    fi
    ;;
  video/*)
    if command -v ffmpegthumbnailer >/dev/null && [[ -n "$KITTY_WINDOW_ID" ]]; then
      ffmpegthumbnailer -i "{}" -o /tmp/thumb.png -s 400 2>/dev/null
      kitty +kitten icat /tmp/thumb.png 2>/dev/null && used=$IMG_HEIGHT || used=1
    else
      echo "🎬 $(basename "{}")"
      used=1
    fi
    ;;
  audio/*)
    echo "🎵 $(basename "{}")"
    used=1
    ;;
  application/pdf)
    if command -v pdftotext >/dev/null; then
      pdftotext -l 10 "{}" - 2>/dev/null | head -n $AVAILABLE
      used=$(pdftotext -l 10 "{}" - 2>/dev/null | wc -l)
    else
      echo "📄 PDF: $(basename "{}")"
      used=1
    fi
    ;;
  application/zip|application/x-tar|application/x-gzip|application/x-bzip2)
    if command -v tar >/dev/null && [[ "{}" =~ \.(tar|tgz|tbz2|gz|bz2)$ ]]; then
      tar -tf "{}" 2>/dev/null | head -n $AVAILABLE
      used=$(tar -tf "{}" 2>/dev/null | wc -l)
    elif command -v unzip >/dev/null; then
      unzip -l "{}" 2>/dev/null | head -n $AVAILABLE
      used=$(unzip -l "{}" 2>/dev/null | wc -l)
    else
      echo "🗜️ Archive: $(basename "{}")"
      used=1
    fi
    ;;
  text/*|application/json|application/javascript|application/xml|application/x-sh)
    if command -v bat >/dev/null; then
      bat --color=always --style=numbers,changes --line-range=:$AVAILABLE "{}" 2>/dev/null
      used=$AVAILABLE
    else
      head -n $AVAILABLE "{}" 2>/dev/null
      used=$(wc -l <<< "$(head -n $AVAILABLE "{}" 2>/dev/null)")
    fi
    ;;
  *)
    if file "{}" | grep -qi "binary"; then
      echo "🔧 Binary file: $(basename "{}")"
      used=1
    else
      head -n $AVAILABLE "{}" 2>/dev/null
      used=$(wc -l <<< "$(head -n $AVAILABLE "{}" 2>/dev/null)")
    fi
    ;;
esac

((used < AVAILABLE)) && printf "\n%.0s" $(seq 1 $((AVAILABLE - used)))
echo "$DIVIDER"
meta  "name:    " "$(basename "{}")"
meta  "size:    " "$(du -sh "{}" 2>/dev/null | cut -f1)"
meta  "type:    " "$(file --mime-type -b "{}" 2>/dev/null)"
meta  "modified:" "$(date -r "{}" "+%Y-%m-%d %H:%M" 2>/dev/null)"
\'
'
export FZF_CTRL_R_OPTS="--preview='' --preview-window=hidden"

#bat
export BAT_THEME_DARK='Dracula'
