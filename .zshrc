# ~/.zshrc
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS

# 0. User FPATH (Declared before OMZ compinit)
fpath=(
    /home/medhansh/.local/share/zsh/site-functions
    /home/medhansh/.local/share/college/completions
    $fpath
)

# 1. Environment & Paths (Deduplicated)
export PATH="$HOME/.local/bin:$HOME/.lmstudio/bin:$HOME/.kimi-code/bin:$PATH"
export CLAUDE_CODE_USE_BEDROCK=1
export AWS_REGION=us-east-1

# 2. Define Directory dynamically & Disable Oh My Zsh auto-updates
ZSH_MOD_DIR="${ZDOTDIR:-$HOME}/.zsh"
DISABLE_AUTO_UPDATE="true"

# 3. Load modules in order
for file in \
    00-env \
    20-omz \
    30-aliases \
    35-zoxide \
    40-tools \
    90-prompt \
    95-startup; do
    [[ -r "$ZSH_MOD_DIR/$file.zsh" ]] && source "$ZSH_MOD_DIR/$file.zsh"
done

eval "$(fzf --zsh)"

zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --icons $realpath'

[[ -f "${ZDOTDIR:-$HOME}/.p10k-colors.zsh" ]] && source "${ZDOTDIR:-$HOME}/.p10k-colors.zsh"

# Hyprland dots configuration
if [[ -f ~/.config/zshrc.d/dots-hyprland.zsh ]]; then
    source ~/.config/zshrc.d/dots-hyprland.zsh
fi
