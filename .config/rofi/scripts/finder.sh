#!/usr/bin/env bash

FD=$(command -v fd || command -v fdfind) || exit 1
HIST="$HOME/.cache/rofi_file_history"
mkdir -p "$(dirname "$HIST")"
touch "$HIST"

# ---------------- SELECTION ----------------
if [ -n "$ROFI_INFO" ]; then
    FILE="$ROFI_INFO"

    grep -vxF "$FILE" "$HIST" > "$HIST.tmp" 2>/dev/null
    { echo "$FILE"; cat "$HIST.tmp"; } | head -n 15 > "$HIST"
    rm -f "$HIST.tmp"

    xdg-open "$FILE" >/dev/null 2>&1 &
    disown
    exit 0
fi

QUERY="$1"

# ---------------- SHARED FORMATTER ----------------
format() {
    MODE="$1"   # normal | history
    perl -e '
        use strict;
        use warnings;

        my $mode = shift @ARGV;

        while (<STDIN>) {
            chomp;
            my $f = $_;

            my @p = split("/", $f);
            my $name = pop(@p);
            my $parent = pop(@p) // "root";

            # -------- ICON RESOLUTION (NERD FONTS ONLY) --------
            my $icon = "󰈙";  # generic file

            # Programming languages
            if    ($name =~ /\.c$/i)        { $icon = "󰙱"; }  # C
            elsif ($name =~ /\.h$/i)        { $icon = "󰙱"; }  # Header
            elsif ($name =~ /\.cpp$/i)      { $icon = "󰙲"; }  # C++
            elsif ($name =~ /\.hpp$/i)      { $icon = "󰙲"; }  # C++ Header
            elsif ($name =~ /\.rs$/i)       { $icon = "󱘗"; }  # Rust
            elsif ($name =~ /\.go$/i)       { $icon = "󰟓"; }  # Go
            elsif ($name =~ /\.py$/i)       { $icon = "󰌠"; }  # Python
            elsif ($name =~ /\.js$/i)       { $icon = "󰌞"; }  # JavaScript
            elsif ($name =~ /\.ts$/i)       { $icon = "󰛦"; }  # TypeScript
            elsif ($name =~ /\.java$/i)     { $icon = "󰬷"; }  # Java
            elsif ($name =~ /\.sh$/i)       { $icon = "󰆍"; }  # Shell
            elsif ($name =~ /\.lua$/i)      { $icon = "󰢱"; }  # Lua
            elsif ($name =~ /\.rb$/i)       { $icon = "󰴭"; }  # Ruby
            elsif ($name =~ /\.php$/i)      { $icon = "󰌟"; }  # PHP

            # Documents / data
            elsif ($name =~ /\.pdf$/i)              { $icon = "󰈦"; }
            elsif ($name =~ /\.(md|txt|log)$/i)     { $icon = "󰈙"; }
            elsif ($name =~ /\.(json|ya?ml|xml)$/i) { $icon = "󰘦"; }
            elsif ($name =~ /\.(csv|xls|xlsx|ods)$/i) { $icon = "󰈛"; }
            elsif ($name =~ /\.(doc|docx|odt|rtf)$/i) { $icon = "󰈬"; }

            # Media
            elsif ($name =~ /\.(png|jpg|jpeg|gif|svg|webp)$/i) { $icon = "󰋩"; }
            elsif ($name =~ /\.(mp4|mkv|avi|mov|webm)$/i)      { $icon = "󰕧"; }
            elsif ($name =~ /\.(mp3|wav|flac|ogg)$/i)          { $icon = "󰎈"; }

            # Archives / binaries
            elsif ($name =~ /\.(zip|tar|gz|bz2|xz|7z)$/i) { $icon = "󰀼"; }
            elsif ($name =~ /\.(AppImage|exe|bin|run)$/i) { $icon = "󰆍"; }

            # -------- ESCAPE --------
            for ($name, $parent) {
                s/&/&amp;/g;
                s/</&lt;/g;
                s/>/&gt;/g;
            }

            # -------- OUTPUT --------
            if ($mode eq "history") {
                print "<span foreground=\"#b0b0b0\">$icon  $name</span> ";
            } else {
                print "$icon      $name ";
            }

            print "<span color=\"#6272a4\" size=\"small\">($parent)</span>\0info\x1f$f\n";
        }
    ' "$MODE"
}



print_separator() {
    echo -en "── Recent Files ──────────────────────────\0nonselectable\x1ftrue\n"
}

# ---------------- HISTORY ----------------
HISTORY_PRINTED=0

if [ -s "$HIST" ]; then
    if [ -n "$QUERY" ]; then
        grep -i "$QUERY" "$HIST" | head -n 5 | format history
    else
        head -n 5 "$HIST" | format history
    fi
    HISTORY_PRINTED=1
fi

[ "$HISTORY_PRINTED" -eq 1 ] && print_separator

# ---------------- SEARCH TIERS ----------------

$FD "$QUERY" "$HOME/Downloads" \
    --type f --hidden --exclude .git --color never 2>/dev/null |
    head -n 150000 | format normal && exit 0

$FD "$QUERY" "$HOME/Documents" \
    --type f --hidden --exclude .git --color never 2>/dev/null |
    head -n 150000 | format normal && exit 0

if [ ${#QUERY} -ge 3 ]; then
    $FD "$QUERY" "$HOME" \
        --type f --hidden \
        --exclude .git --exclude node_modules \
        --exclude Downloads --exclude Documents \
        --max-depth 6 \
        --color never 2>/dev/null |
        head -n 50 | format normal
fi
