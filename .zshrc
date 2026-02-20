# ~/.zshrc

# 1. Start Instant Prompt IMMEDIATELY
# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#   source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi

# 2. Define Directory
ZSH_MOD_DIR="$HOME/.zsh"

# 3. Load modules in order
# Removed 10-instant from the loop because it's already handled above
for file in \
  00-env \
  20-omz \
  30-aliases \
  35-zoxide \
  40-tools \
  90-prompt \
  95-startup
do
  [[ -r "$ZSH_MOD_DIR/$file.zsh" ]] && source "$ZSH_MOD_DIR/$file.zsh"
done
# Created by `pipx` on 2026-02-05 09:35:10
export PATH="$PATH:/home/medhansh/.local/bin"
export PATH="$HOME/.local/bin:$PATH"


eval "$(atuin init zsh)"
