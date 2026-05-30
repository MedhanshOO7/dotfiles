#!/bin/bash
# Post-hook script for matugen: injects generated colors into dev-dashboard.html
# Reads dev-dashboard-colors.css and replaces the block between MATUGEN markers

COLORS_FILE="$HOME/Downloads/dev-dashboard-colors.css"
DASHBOARD="$HOME/Downloads/dev-dashboard.html"

if [ ! -f "$COLORS_FILE" ] || [ ! -f "$DASHBOARD" ]; then
  exit 0
fi

python3 << 'PYEOF'
import re, os

colors_file = os.path.expanduser("~/Downloads/dev-dashboard-colors.css")
dashboard = os.path.expanduser("~/Downloads/dev-dashboard.html")

# Read the CSS variables
with open(colors_file, 'r') as f:
    css_lines = f.readlines()

# Extract only the --var lines
var_lines = [line for line in css_lines if line.strip().startswith('--')]
if not var_lines:
    exit(0)

vars_text = ''.join(var_lines).rstrip('\n')

# Read the dashboard HTML
with open(dashboard, 'r') as f:
    content = f.read()

# Replace everything between the markers
pattern = r'(/\* MATUGEN-START \*/)\n.*?\n(  /\* MATUGEN-END \*/)'
replacement = r'\g<1>\n' + vars_text + r'\n\g<2>'
new_content = re.sub(pattern, replacement, content, flags=re.DOTALL)

if new_content != content:
    with open(dashboard, 'w') as f:
        f.write(new_content)

PYEOF
