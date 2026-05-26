# ~/.zshrc
#
# 1. Define Directory dynamically
ZSH_MOD_DIR="${ZDOTDIR:-$HOME}/.zsh"

# 2. Disable Oh My Zsh auto-updates (prevents console output)
DISABLE_AUTO_UPDATE="true"

# 3. Load modules in order
# Removed 10-instant from the loop because it's already handled above
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

# Added by LM Studio CLI (lms)
export PATH="$PATH:/home/medhansh/.lmstudio/bin"
# End of LM Studio CLI section

export PATH="$HOME/.local/bin:$PATH"
[[ -f "${ZDOTDIR:-$HOME}/.p10k-colors.zsh" ]] && source "${ZDOTDIR:-$HOME}/.p10k-colors.zsh"
export CLAUDE_CODE_USE_BEDROCK=1
export AWS_REGION=us-east-1
# Hyprland dots configuration
source ~/.config/zshrc.d/dots-hyprland.zsh

export AWS_REGION=us-east-1


# Added by Antigravity CLI installer
export PATH="/home/medhansh/.local/bin:$PATH"
