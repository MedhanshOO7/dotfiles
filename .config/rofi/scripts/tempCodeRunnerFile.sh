
    my @p=split("/", $f); 
    my $name=pop(@p); 
    my $parent=pop(@p) // ""; 
    
    # --- ICONS & COLORS ---
    my $icon = "📄"; 
    my $color = "#f8f8f2"; # Default White

    if ($name =~ /\.pdf$/i) { $icon = "📕"; $color = "#ff5555"; } 
    elsif ($name =~ /\.(jpe?g|png|gif|webp)$/i) { $icon = "🖼️"; $color = "#bd93f9"; }
    elsif ($name =~ /\.(cpp|c|h|py|js|sh)$/i) { $icon = "💻"; $color = "#50fa7b"; }