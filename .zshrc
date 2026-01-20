# ~/.zshrc — minimal loader

ZSH_MOD_DIR="$HOME/.zsh"

for file in \
  00-env \
  10-instant \
  20-omz \
  30-aliases \
  35-zoxide \
  40-tools \
  90-prompt
do
  [[ -r "$ZSH_MOD_DIR/$file.zsh" ]] && source "$ZSH_MOD_DIR/$file.zsh"
done
