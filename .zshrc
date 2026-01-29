# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ~/.zshrc — minimal loader

ZSH_MOD_DIR="$HOME/.zsh"

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
