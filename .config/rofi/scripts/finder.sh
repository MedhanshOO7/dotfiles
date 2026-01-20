#!/usr/bin/env bash

# 1. Open the file if selected
if [ -n "$ROFI_INFO" ]; then
    coproc xdg-open "$ROFI_INFO" > /dev/null 2>&1
    exit 0
fi

# 2. Search and Format
# We use standard Perl regex to manually escape '&', '<', and '>'
# This prevents Rofi from crashing on filenames with symbols
fd . $HOME --type f --hidden --exclude .git --exclude node_modules --color never \
| perl -pe '
    chomp; 
    my $f=$_; 
    my @p=split("/", $f); 
    my $name=pop(@p); 
    my $parent=pop(@p); 
    
    # Manually escape XML characters for Pango
    foreach ($name, $parent) { s/&/&amp;/g; s/</&lt;/g; s/>/&gt;/g; }
    
    # Print: Name (Parent) [Hidden: Full Path]
    print "$name <span color=\"#6272a4\" size=\"small\">($parent)</span>\0info\x1f$f\n"; 
    $_=""'