# ============================================================
#  Linuwu-Sense Aliases — Acer Predator
#  Add to your ~/.bashrc or ~/.zshrc:
#    source ~/linuwu_aliases.sh
# ============================================================

_MOD=$(ls -d /sys/module/nekro_sense 2>/dev/null || ls -d /sys/module/linuwu_sense 2>/dev/null)
_PS="$_MOD/drivers/platform:acer-wmi/acer-wmi/predator_sense"
_KB="$_MOD/drivers/platform:acer-wmi/acer-wmi/four_zoned_kb"
_LOGO="$_MOD/drivers/platform:acer-wmi/acer-wmi/back_logo"

# ── Thermal Profiles ────────────────────────────────────────
alias profile-get='cat /sys/firmware/acpi/platform_profile'
alias profile-list='cat /sys/firmware/acpi/platform_profile_choices'
alias profile-quiet='echo quiet | sudo tee /sys/firmware/acpi/platform_profile > /dev/null'
alias profile-balanced='echo balanced | sudo tee /sys/firmware/acpi/platform_profile > /dev/null'
alias profile-performance='echo performance | sudo tee /sys/firmware/acpi/platform_profile > /dev/null'
alias profile-turbo='echo performance-boost | sudo tee /sys/firmware/acpi/platform_profile > /dev/null'

# ── Fan Speed ───────────────────────────────────────────────
# Usage: fan-set <cpu_speed>,<gpu_speed>   (0=auto, 1-100)
# Example: fan-set 60,70
alias fan-get='cat $_PS/fan_speed'
alias fan-auto='echo 0,0 | sudo tee $_PS/fan_speed > /dev/null'
alias fan-max='echo 100,100 | sudo tee $_PS/fan_speed > /dev/null'
alias fan-set='_fan_set(){ echo "$1" | sudo tee $_PS/fan_speed > /dev/null; }; _fan_set'

# ── RGB / Keyboard Lighting ─────────────────────────────────
# Per-zone static colors (hex RRGGBB per zone, then brightness 0-100)
# Usage: kb-color <z1>,<z2>,<z3>,<z4>,<brightness>
# Example: kb-color ff0000,00ff00,0000ff,ff00ff,100
alias kb-get='cat $_KB/per_zone_mode'
# NOTE: brightness is kept at 1 for black/off to prevent Embedded Controller (EC) RGB MCU lockup
alias kb-off='echo 000000,000000,000000,000000,1 | sudo tee $_KB/per_zone_mode > /dev/null'
alias kb-white='echo ffffff,ffffff,ffffff,ffffff,100 | sudo tee $_KB/per_zone_mode > /dev/null'
alias kb-default='echo 00BFFF,00BFFF,00BFFF,00BFFF,100 | sudo tee $_KB/per_zone_mode > /dev/null'
alias kb-red='echo ff0000,ff0000,ff0000,ff0000,100 | sudo tee $_KB/per_zone_mode > /dev/null'
alias kb-blue='echo 0000ff,0000ff,0000ff,0000ff,100 | sudo tee $_KB/per_zone_mode > /dev/null'
alias kb-green='echo 00ff00,00ff00,00ff00,00ff00,100 | sudo tee $_KB/per_zone_mode > /dev/null'
alias kb-color='_kb_color(){ echo "$1" | sudo tee $_KB/per_zone_mode > /dev/null; }; _kb_color'
alias kb-sync='
WALL=$(jq -r ".wallpaper" ~/.cache/wal/colors.json)

COLOR=$(magick "$WALL" \
-resize 100x100 \
-colors 6 \
-format "%c" histogram:info:- \
| sort -nr \
| head -1 \
| grep -o "#[0-9A-Fa-f]\{6\}" \
| tr -d "#" \
| tr "[:upper:]" "[:lower:]")

printf "%s,%s,%s,%s,100" \
"$COLOR" "$COLOR" "$COLOR" "$COLOR" \
| sudo tee $_KB/per_zone_mode > /dev/null
'

# RGB Effects (mode, speed, brightness, direction, R, G, B)
# Modes: 0=static 1=breathing 2=neon 3=wave 4=shifting 5=zoom 6=meteor 7=twinkling
# Direction: 1=right-to-left  2=left-to-right
alias kb-mode-get='cat $_KB/four_zone_mode'
alias kb-static='echo 0,1,100,1,255,255,255 | sudo tee $_KB/four_zone_mode > /dev/null'
alias kb-breathing='echo 1,5,100,1,0,120,255 | sudo tee $_KB/four_zone_mode > /dev/null'
alias kb-neon='echo 2,5,100,1,0,0,0 | sudo tee $_KB/four_zone_mode > /dev/null'
alias kb-wave='echo 3,5,100,2,0,0,0 | sudo tee $_KB/four_zone_mode > /dev/null'
alias kb-meteor='echo 6,5,100,2,0,120,255 | sudo tee $_KB/four_zone_mode > /dev/null'
alias kb-twinkling='echo 7,5,100,1,255,255,255 | sudo tee $_KB/four_zone_mode > /dev/null'
# Usage: kb-mode <mode>,<speed>,<brightness>,<direction>,<R>,<G>,<B>
alias kb-mode='_kb_mode(){ echo "$1" | sudo tee $_KB/four_zone_mode > /dev/null; }; _kb_mode'

# Backlight timeout (turns off RGB after 30s idle)
alias kb-timeout-on='echo 1 | sudo tee $_PS/backlight_timeout > /dev/null'
alias kb-timeout-off='echo 0 | sudo tee $_PS/backlight_timeout > /dev/null'
alias kb-timeout-get='cat $_PS/backlight_timeout'

# ── Cover Logo / Lightbar ─────────────────────────────────
alias logo-get='cat $_LOGO/color 2>/dev/null || echo "Logo sysfs node not available"'
alias logo-on='echo "FFFFFF,100,1" | sudo tee $_LOGO/color > /dev/null'
alias logo-off='echo "000000,0,0" | sudo tee $_LOGO/color > /dev/null'
alias logo-white='echo "FFFFFF,100,1" | sudo tee $_LOGO/color > /dev/null'
alias logo-red='echo "FF0000,100,1" | sudo tee $_LOGO/color > /dev/null'
alias logo-blue='echo "0000FF,100,1" | sudo tee $_LOGO/color > /dev/null'
alias logo-cyan='echo "00BFFF,100,1" | sudo tee $_LOGO/color > /dev/null'
alias logo-green='echo "00FF00,100,1" | sudo tee $_LOGO/color > /dev/null'
alias logo-purple='echo "8A2BE2,100,1" | sudo tee $_LOGO/color > /dev/null'
alias logo-gold='echo "FFD700,100,1" | sudo tee $_LOGO/color > /dev/null'
# Usage: logo-color <RRGGBB> [brightness] [enable]
# Example: logo-color FF6600 100 1
alias logo-color='_logo_color(){ echo "${1:-FFFFFF},${2:-100},${3:-1}" | sudo tee $_LOGO/color > /dev/null; }; _logo_color'

# ── RGB Reset / Driver Reload ─────────────────────────────
alias kb-reset='sudo modprobe -r nekro_sense 2>/dev/null || sudo rmmod linuwu_sense 2>/dev/null; sudo modprobe nekro_sense 2>/dev/null || sudo modprobe linuwu_sense predator_v4=1 2>/dev/null; echo "RGB Driver Reset Complete"'

# ── Battery ─────────────────────────────────────────────────
alias bat-limit-on='echo 1 | sudo tee $_PS/battery_limiter > /dev/null' # limit charge to 80%
alias bat-limit-off='echo 0 | sudo tee $_PS/battery_limiter > /dev/null'
alias bat-limit-get='cat $_PS/battery_limiter'

alias bat-calibrate-start='echo 1 | sudo tee $_PS/battery_calibration > /dev/null'
alias bat-calibrate-stop='echo 0 | sudo tee $_PS/battery_calibration > /dev/null'
alias bat-calibrate-get='cat $_PS/battery_calibration'

# ── USB Charging (when laptop is off) ───────────────────────
alias usb-charge-off='echo 0 | sudo tee $_PS/usb_charging > /dev/null'
alias usb-charge-10='echo 10 | sudo tee $_PS/usb_charging > /dev/null' # charge until bat < 10%
alias usb-charge-20='echo 20 | sudo tee $_PS/usb_charging > /dev/null'
alias usb-charge-30='echo 30 | sudo tee $_PS/usb_charging > /dev/null'
alias usb-charge-get='cat $_PS/usb_charging'

# ── LCD Override (reduce latency / ghosting) ────────────────
alias lcd-override-on='echo 1 | sudo tee $_PS/lcd_override > /dev/null'
alias lcd-override-off='echo 0 | sudo tee $_PS/lcd_override > /dev/null'
alias lcd-override-get='cat $_PS/lcd_override'

# ── Boot Animation & Sound ──────────────────────────────────
alias boot-anim-on='echo 1 | sudo tee $_PS/boot_animation_sound > /dev/null'
alias boot-anim-off='echo 0 | sudo tee $_PS/boot_animation_sound > /dev/null'
alias boot-anim-get='cat $_PS/boot_animation_sound'

# ── Quick Status ─────────────────────────────────────────────
alias predator-status='
  echo "=== Linuwu-Sense Status ==="
  echo -n "Thermal profile : "; cat /sys/firmware/acpi/platform_profile
  echo -n "Fan speed       : "; cat $_PS/fan_speed
  echo -n "Keyboard RGB    : "; cat $_KB/per_zone_mode
  echo -n "KB timeout      : "; cat $_PS/backlight_timeout
  echo -n "Battery limiter : "; cat $_PS/battery_limiter
  echo -n "USB charging    : "; cat $_PS/usb_charging
  echo -n "LCD override    : "; cat $_PS/lcd_override
  echo -n "Boot animation  : "; cat $_PS/boot_animation_sound
'

# ── Battery Health Limiter (80% Care Mode) ──────────────────
alias battery-limit-get='cat $_PS/battery_limiter'
alias battery-limit-on='echo 1 | sudo tee $_PS/battery_limiter > /dev/null && echo "Battery limit set to 80% (Care Mode 🌿)"'
alias battery-limit-off='echo 0 | sudo tee $_PS/battery_limiter > /dev/null && echo "Battery limit disabled (Charging to 100% ⚡)"'
