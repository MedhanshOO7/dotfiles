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

#video Downloading 
alias ytv='yt-dlp \
-f "bv*+ba/b" \
--embed-metadata \
--add-metadata \
--embed-thumbnail \
--write-info-json \
--write-description \
--embed-chapters \
--convert-thumbnails jpg \
-o "%(title)s.%(ext)s"'

# video to mvk
alias ytm='yt-dlp \
-f "bv*+ba/b" \
--merge-output-format mkv \
--embed-metadata \
--add-metadata \
--embed-thumbnail \
--write-info-json \
--write-description \
--embed-chapters \
--convert-thumbnails jpg \
-o "%(title)s.%(ext)s"'

# video and subtitles
alias yts='yt-dlp \
-f "bv*+ba/b" \
--write-subs \
--sub-langs "en" \
--convert-subs srt \
--embed-subs \
--merge-output-format mkv \
--embed-metadata \
--add-metadata \
--embed-thumbnail \
--write-info-json \
--write-description \
--embed-chapters \
--convert-thumbnails jpg \
-o "%(title)s.%(ext)s"'

# audio downloading 
alias yta='yt-dlp \
-f bestaudio \
-x \
--audio-format mp3 \
--audio-quality 0 \
--embed-metadata \
--add-metadata \
--embed-thumbnail \
--embed-chapters \
--convert-thumbnails jpg \
--parse-metadata "title:%(artist)s - %(title)s" \
--metadata-from-title "%(artist)s - %(title)s" \
-o "%(title)s.%(ext)s"'


