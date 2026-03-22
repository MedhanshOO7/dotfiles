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
if [ -d {} ]; then
  eza --icons --tree --level=2 --color=always {}
else
  case {} in
    *.png|*.jpg|*.jpeg|*.webp|*.gif)
      kitty +kitten icat --clear --transfer-mode=memory --stdin no {} ;;
    *)
      if file --mime {} | grep -q binary; then
        echo "Binary file"
      else
        bat --color=always --line-range=:300 {}
      fi ;;
  esac
fi
\'
'
#bat
export BAT_THEME_DARK='Dracula'
