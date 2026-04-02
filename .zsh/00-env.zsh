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
export MANPAGER="less -R --use-color "

#FZF
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
printf "\033_Ga=d,d=A\033\\\\"

IMG_HEIGHT=18
META_LINES=6
DIVIDER=$(printf "%-${FZF_PREVIEW_COLUMNS}s" "" | tr " " "─")
RESET="\033[0m"
LABEL="\033[38;2;140;170;238m"
VALUE="\033[38;2;198;208;245m"
ICON="\033[38;2;166;209;137m"

meta() {
  echo -e "${ICON}$1${RESET}  ${LABEL}$2${RESET}  ${VALUE}$3${RESET}"
}

pad_to_bottom() {
  local used=$1
  local remaining=$((FZF_PREVIEW_LINES - used - META_LINES - 1))
  [ $remaining -gt 0 ] && printf "\n%.0s" $(seq 1 $remaining)
}

if [ -d {} ]; then
  eza --icons --tree --level=2 --color=always {} | head -n $((FZF_PREVIEW_LINES - META_LINES - 1))
  pad_to_bottom $((FZF_PREVIEW_LINES - META_LINES - 1))
  echo "$DIVIDER"
  meta "📁" "name:    " "$(basename {})"
  meta "📦" "items:   " "$(ls {} | wc -l)"
  meta "💾" "size:    " "$(du -sh {} 2>/dev/null | cut -f1)"
  meta "🕒" "modified:" "$(date -r {} "+%Y-%m-%d %H:%M")"
else
  case {} in
    *.png|*.jpg|*.jpeg|*.webp|*.gif)
      kitty +kitten icat --transfer-mode=memory --stdin no --scale-up \
        --place ${FZF_PREVIEW_COLUMNS}x${IMG_HEIGHT}@0x0 {} 2>/dev/null
      pad_to_bottom $IMG_HEIGHT
      echo "$DIVIDER"
      meta "🖼 " "name:    " "$(basename {})"
      meta "💾" "size:    " "$(du -sh {} | cut -f1)"
      meta "📐" "dims:    " "$(identify -format "%wx%h" {} 2>/dev/null || echo "N/A")"
      meta "🕒" "modified:" "$(date -r {} "+%Y-%m-%d %H:%M")" ;;
    *)
      if file --mime {} | grep -q binary; then
        echo "Binary file"
        pad_to_bottom 1
      else
        bat --color=always --line-range=:$((FZF_PREVIEW_LINES - META_LINES - 1)) {} 2>/dev/null
        pad_to_bottom $((FZF_PREVIEW_LINES - META_LINES - 1))
      fi
      echo "$DIVIDER"
      meta "📄" "name:    " "$(basename {})"
      meta "💾" "size:    " "$(du -sh {} | cut -f1)"
      meta "🔖" "type:    " "$(file --mime-type -b {})"
      meta "🕒" "modified:" "$(date -r {} "+%Y-%m-%d %H:%M")" ;;
  esac
fi
\'
'
#bat
export BAT_THEME_DARK='Dracula'
