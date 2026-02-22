# File manager
alias files="dolphin"

# Clipboard
alias clip="wl-copy"

# Modern ls (eza)
alias ls='eza --icons --sort=extension --group-directories-first --git'
alias ll='eza -lah --icons --group-directories-first --git --time-style=long-iso'
alias la='eza -a'
alias lt='eza --tree --level=2 --icons --group-directories-first'
alias ltd='eza --tree --level=4 --icons --group-directories-first'
alias lsd='eza -D --icons'
alias lsf='eza -f --icons'

# ProtonVPN
alias vpn='protonvpn'
alias vpnc='protonvpn connect'
alias vpndc='protonvpn disconnect'

#zoxide
alias cdi='zi'

# Editor
#alias code='codium'

#yt-dlp

# Best quality video (auto container)
alias ytv='yt-dlp -f "bv*+ba/b"'

# Best quality forced MKV
alias ytm='yt-dlp -f "bv*+ba/b" --merge-output-format mkv'

# Video + English subtitles embedded
alias yts='yt-dlp -f "bv*+ba/b" --write-subs --sub-langs "en" --convert-subs srt --embed-subs --merge-output-format mkv'

# Audio only (best quality m4a)
alias yta='yt-dlp -x --audio-format m4a --embed-metadata'

# Show available formats
alias ytf='yt-dlp -F'
