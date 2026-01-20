#!/usr/bin/env bash

# --- CONFIGURATION ---
# 1. Set your main folder
WALLPAPER_DIR="$HOME/Pictures/walpapers/walls/"
# ---------------------

# 2. If an image was selected, apply it
if [ -n "$ROFI_INFO" ]; then
    # Try 'feh' first (Standard for Arch/i3/Bspwm)
    if command -v feh >/dev/null 2>&1; then
        feh --bg-scale "$ROFI_INFO"
        notify-send "Wallpaper Set" "$(basename "$ROFI_INFO")"
        exit 0
    fi
    
    # Fallback: If you are actually on KDE Plasma (since I saw plasma apps in your screenshot)
    # feh might not work. Uncomment the line below if nothing happens:
    # qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "var allDesktops = desktops();print (allDesktops);for (i=0;i<allDesktops.length;i++) {d = allDesktops[i];d.wallpaperPlugin = \"org.kde.image\";d.currentConfigGroup = Array(\"Wallpaper\", \"org.kde.image\", \"General\");d.writeConfig(\"Image\", \"file://$ROFI_INFO\")}"
    
    exit 0
fi

# 3. List the images with Subfolder context
# We use the same Perl trick as the Finder to show: Name (Subfolder)
# We also pass the image path to '\0icon\x1f' so Rofi renders the image as the icon
find -L "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" -o -iname "*.webp" \) | \
sort | \
perl -pe '
    chomp;
    my $f=$_;
    my @p=split("/", $f);
    my $name=pop(@p);
    my $parent=pop(@p);
    # Print: Name <grey>(Parent Folder)</grey> + Icon(TheImage) + Info(Path)
    print "$name <span color=\"#6272a4\" size=\"small\">($parent)</span>\0icon\x1f$f\0info\x1f$f\n"; 
    $_=""'
