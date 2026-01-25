#!/usr/bin/env bash

# --- CONFIG ---
HIST_FILE="$HOME/.cache/rofi-finder-history"
if [ ! -f "$HIST_FILE" ]; then mkdir -p "$(dirname "$HIST_FILE")"; touch "$HIST_FILE"; fi

# --- 1. HANDLE SELECTION ---
if [ -n "$ROFI_INFO" ]; then
  grep -vxF "$ROFI_INFO" "$HIST_FILE" > "$HIST_FILE.tmp" 2>/dev/null && mv "$HIST_FILE.tmp" "$HIST_FILE"
  echo "$ROFI_INFO" >> "$HIST_FILE"
  nohup xdg-open "$ROFI_INFO" > /dev/null 2>&1 &
  exit 0
fi
if [[ "$@" == /* ]] && [ -e "$@" ]; then
  grep -vxF "$@" "$HIST_FILE" > "$HIST_FILE.tmp" 2>/dev/null && mv "$HIST_FILE.tmp" "$HIST_FILE"
  echo "$@" >> "$HIST_FILE"
  nohup xdg-open "$@" > /dev/null 2>&1 &
  exit 0
fi

# --- 2. DEFINE SOURCE ---
if [ -z "$@" ]; then
    INPUT_SOURCE="tac $HIST_FILE 2>/dev/null | head -n 20"
    echo -en "\0prompt\x1fHistory\n"
else
    INPUT_SOURCE="baloosearch6 \"$@\" 2>/dev/null | head -n 60"
    echo -en "\0prompt\x1fSearch\n"
fi

# --- 3. FORMAT & DISPLAY ---
eval "$INPUT_SOURCE" | perl -pe '
    chomp; 
    my $f=$_; 
    if (-e $f) {
        my @p=split("/", $f); 
        my $name=pop(@p); 
        my $parent=pop(@p) // ""; 
        
        # --- CATPPUCCIN MOCHA PALETTE ---
        my $rosewater="#f5e0dc"; my $flamingo="#f2cdcd"; my $pink="#f5c2e7";
        my $mauve="#cba6f7";     my $red="#f38ba8";      my $maroon="#eba0ac";
        my $peach="#fab387";     my $yellow="#f9e2af";   my $green="#a6e3a1";
        my $teal="#94e2d5";      my $sky="#89dceb";      my $sapphire="#74c7ec";
        my $blue="#89b4fa";      my $lavender="#b4befe"; my $text="#cdd6f4"; 
        my $overlay="#6c7086";

        my $icon = "📄"; 
        my $color = $text;
        
        # --- 1. DEVELOPER FILES ---
        if    ($name =~ /\.py$/i)       { $icon = "🐍"; $color = $yellow; }
        elsif ($name =~ /\.(cpp|c|h|hpp)$/i) { $icon = "🇨"; $color = $blue; } # C/C++
        elsif ($name =~ /\.(js|ts|jsx|tsx)$/i) { $icon = "📜"; $color = $yellow; } # JS
        elsif ($name =~ /\.rs$/i)       { $icon = "🦀"; $color = $peach; } # Rust
        elsif ($name =~ /\.go$/i)       { $icon = "🐹"; $color = $teal; } # Go
        elsif ($name =~ /\.java$/i)     { $icon = "☕"; $color = $maroon; } # Java
        elsif ($name =~ /\.(rb|ruby)$/i){ $icon = "💎"; $color = $red; } # Ruby
        elsif ($name =~ /\.(php)$/i)    { $icon = "🐘"; $color = $lavender; } # PHP
        elsif ($name =~ /\.(html|htm)$/i){ $icon = "🌐"; $color = $peach; }
        elsif ($name =~ /\.(css|scss)$/i){ $icon = "🎨"; $color = $blue; }
        elsif ($name =~ /\.(sh|bash|zsh|fish)$/i){ $icon = "🐚"; $color = $green; }
        elsif ($name =~ /(dockerfile|docker-compose)/i){ $icon = "🐳"; $color = $blue; }
        elsif ($name =~ /\.(sql|db|sqlite)$/i)   { $icon = "🛢️"; $color = $yellow; }

        # --- 2. DOCUMENTS ---
        elsif ($name =~ /\.pdf$/i)      { $icon = "📕"; $color = $red; }
        elsif ($name =~ /\.(doc|docx)$/i){ $icon = "📘"; $color = $blue; }
        elsif ($name =~ /\.(xls|xlsx|csv)$/i){ $icon = "📊"; $color = $green; }
        elsif ($name =~ /\.(ppt|pptx)$/i){ $icon = "📢"; $color = $peach; }
        elsif ($name =~ /\.md$/i)       { $icon = "📓"; $color = $lavender; }
        elsif ($name =~ /\.(txt|rtf|log)$/i){ $icon = "📝"; $color = $text; }
        elsif ($name =~ /\.(epub|mobi)$/i){ $icon = "📚"; $color = $rosewater; }
        elsif ($name =~ /\.(tex|bib)$/i){ $icon = "📜"; $color = $teal; }

        # --- 3. MEDIA ---
        elsif ($name =~ /\.(jpg|jpeg|png)$/i){ $icon = "🖼️"; $color = $mauve; }
        elsif ($name =~ /\.(svg|ai|eps)$/i)  { $icon = "📐"; $color = $peach; }
        elsif ($name =~ /\.(gif|webp)$/i)    { $icon = "👾"; $color = $pink; }
        elsif ($name =~ /\.(mp4|mkv|mov)$/i) { $icon = "🎬"; $color = $mauve; }
        elsif ($name =~ /\.(mp3|wav|flac)$/i){ $icon = "🎧"; $color = $yellow; }

        # --- 4. CONFIG & SYSTEM ---
        elsif ($name =~ /\.(json|xml|yaml|yml|toml)$/i){ $icon = "🔧"; $color = $sky; }
        elsif ($name =~ /\.(conf|ini|cfg)$/i){ $icon = "⚙️"; $color = $overlay; }
        elsif ($name =~ /\.(zip|tar|gz|rar|7z)$/i){ $icon = "📦"; $color = $flamingo; }
        elsif ($name =~ /\.(iso|img)$/i)     { $icon = "💿"; $color = $pink; }
        elsif ($name =~ /\.(exe|bin|appimage)$/i){ $icon = "🚀"; $color = $green; }
        elsif ($name =~ /\.(pem|key|crt)$/i) { $icon = "🔒"; $color = $red; }
        elsif (-d $f) { $icon = "📂"; $color = $blue; }

        # Escape Special Chars
        $name =~ s/&/&amp;/g; $name =~ s/</&lt;/g; $name =~ s/>/&gt;/g;
        $parent =~ s/&/&amp;/g; $parent =~ s/</&lt;/g; $parent =~ s/>/&gt;/g;
        
        # Output
        print "$icon <span color=\"$color\">$name</span> <span color=\"$overlay\" size=\"small\">($parent)</span>\0info\x1f$f\n";
    }
    $_=""'