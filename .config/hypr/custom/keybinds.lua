-- hyprlang noerror false
-- https://wiki.hyprland.org/Configuring/Binds/

local SUPER = "SUPER"
local SHIFT = "SHIFT"
local ALT = "ALT"
local CTRL = "CTRL"

-- ##! User
hl.bind(CTRL .. " + SUPER + Slash", hl.dsp.exec_cmd("xdg-open ~/.config/illogical-impulse/config.json")) -- Edit shell config
hl.bind(CTRL .. " + SUPER + ALT + Slash", hl.dsp.exec_cmd("xdg-open ~/.config/hypr/custom/keybinds.lua")) -- Edit extra keybinds

-- ##! Apps
-- unbinds
hl.unbind("SUPER + SHIFT + X")

-- vicinae
hl.unbind("ALT + SPACE")
hl.bind("ALT + SPACE", hl.dsp.exec_cmd("vicinae toggle"))

-- alt-tab (snappy-switcher)
hl.bind("ALT + Tab", hl.dsp.exec_cmd("snappy-switcher next --mod alt"))
hl.bind("ALT + SHIFT + Tab", hl.dsp.exec_cmd("snappy-switcher prev --mod alt"))

-- window management
hl.unbind("SUPER + W")
hl.bind("SUPER + W", hl.dsp.window.close())
hl.bind("ALT + Return", hl.dsp.window.fullscreen({ mode = "fullscreen" }))

-- browser
hl.unbind("SUPER + B")
hl.bind("SUPER + B", hl.dsp.exec_cmd(browser))

-- OCR / translate
hl.unbind("SUPER + SHIFT + T")
hl.bind("SUPER + SHIFT + T", hl.dsp.exec_cmd("~/.config/hypr/custom/scripts/ocr.sh"),
    { description = "Utilities: OCR region >> clipboard" })
hl.bind("SUPER + SHIFT + Y", hl.dsp.exec_cmd("~/.config/hypr/custom/scripts/ocr.sh --translate"),
    { description = "Utilities: Translate region (Google Translate)" })

-- recording
hl.unbind("SUPER + SHIFT + R")
hl.bind(
    "SUPER + SHIFT + R",
    hl.dsp.exec_cmd("~/.config/hypr/custom/scripts/record.sh --fullscreen --sound"),
    { locked = true }
)
hl.unbind("SUPER + SHIFT + ALT + R")
hl.bind(
    "SUPER + SHIFT + ALT + R",
    hl.dsp.exec_cmd("~/.config/hypr/custom/scripts/record.sh --sound"),
    { locked = true }
)

-- Obsidian
hl.unbind("SUPER + O")
hl.bind("SUPER + O", hl.dsp.exec_cmd("obsidian"))

-- SUPER + Q is left free (windows close with SUPER + W; SUPER + A is the waybar control center)
hl.unbind("SUPER + Q")

-- hyprltm-net
hl.unbind("SUPER + N")
hl.bind("SUPER + N", hl.dsp.exec_cmd("/home/medhansh/.local/bin/hyprltm-net"))

-- PredatorSense Key (Acer Predator Key & Super+P shortcut)
-- opens the Nekro Sense GUI, or focuses it if already open
local predator_gui_cmd = "~/.config/hud/predator.sh gui"
hl.bind("XF86Launch1", hl.dsp.exec_cmd(predator_gui_cmd))
hl.bind("XF86LaunchA", hl.dsp.exec_cmd(predator_gui_cmd))
hl.bind("XF86Tools", hl.dsp.exec_cmd(predator_gui_cmd))
hl.bind("XF86Presentation", hl.dsp.exec_cmd(predator_gui_cmd))
hl.unbind("SUPER + P") -- default: pin window
hl.bind("SUPER + P", hl.dsp.exec_cmd(predator_gui_cmd))

-- ##! Send to workspace (number row + keypad)
-- unbinds
local unbind_codes = {
    10,
    11,
    12,
    13,
    14,
    15,
    16,
    17,
    18,
    19,
    87,
    88,
    89,
    83,
    84,
    85,
    79,
    80,
    81,
    90,
}
for _, code in ipairs(unbind_codes) do
    hl.unbind("SUPER + ALT + code:" .. code)
end

local ws_codes = {
    { code = 10, ws = 1 },
    { code = 11, ws = 2 },
    { code = 12, ws = 3 },
    { code = 13, ws = 4 },
    { code = 14, ws = 5 },
    { code = 15, ws = 6 },
    { code = 16, ws = 7 },
    { code = 17, ws = 8 },
    { code = 18, ws = 9 },
    { code = 19, ws = 10 },
    { code = 87, ws = 1 },
    { code = 88, ws = 2 },
    { code = 89, ws = 3 },
    { code = 83, ws = 4 },
    { code = 84, ws = 5 },
    { code = 85, ws = 6 },
    { code = 79, ws = 7 },
    { code = 80, ws = 8 },
    { code = 81, ws = 9 },
    { code = 90, ws = 10 },
}
for _, entry in ipairs(ws_codes) do
    hl.bind("SUPER + SHIFT + code:" .. entry.code, hl.dsp.window.move({ workspace = entry.ws, follow = false }))
end
-- predator key
-- predator key
-- hl.bind("XF86Presentation", hl.dsp.exec_cmd([[kitty -1 sh -c "~/.predatorThings | less -R"]]))
-- easy effects
hl.bind("SUPER + SHIFT + E", hl.dsp.exec_cmd([[easyeffects]]))
-- hl.bind("SUPER + SHIFT + V", hl.dsp.exec_cmd([[pavucontrol]]))
hl.bind("SUPER + SHIFT + U", hl.dsp.exec_cmd([[~/.local/bin/toggle-audio]]))
hl.bind("SUPER + ALT + U", hl.dsp.exec_cmd([[~/.local/bin/toggle-audio --menu]]))

hl.unbind("SUPER + SHIFT + S")
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd("bash $HOME/.config/hypr/custom/scripts/screenshot.sh"),
    { description = "Screenshot: click a window or drag a region (any monitor), then annotate" })
hl.unbind("Print") -- default: grim >> clipboard
hl.bind("Print", hl.dsp.exec_cmd("bash $HOME/.config/hypr/custom/scripts/screenshot.sh --full"),
    { description = "Screenshot: Monitor under the cursor" })
hl.unbind("ALT + Print")
hl.bind("ALT + Print", hl.dsp.exec_cmd("bash $HOME/.config/hypr/custom/scripts/screenshot.sh --window"),
    { description = "Screenshot: Window under the cursor" })

hl.unbind("ALT + F4")
hl.bind("ALT + F4", hl.dsp.exec_cmd("~/.config/hypr/custom/scripts/session-menu.sh"),
    { description = "Session: Session menu" })
hl.unbind("CTRL + ALT + Delete")
hl.bind("CTRL + ALT + Delete", hl.dsp.exec_cmd("~/.config/hypr/custom/scripts/session-menu.sh"))

-- ##! Screen Lock
hl.unbind("SUPER + L")
hl.bind("SUPER + L", hl.dsp.exec_cmd("pidof hyprlock || hyprlock"), { description = "Session: Lock screen" })
hl.unbind("SUPER + SHIFT + L")
hl.bind("SUPER + SHIFT + L", hl.dsp.exec_cmd("pkill -x hyprlock || hyprlock"), { description = "Session: Toggle lock" })

-- ##! Multi-Monitor Management
-- SUPER + period is the emoji picker (see below), so SUPER + comma cycles monitors
hl.bind(
    "SUPER + comma",
    hl.dsp.focus({ monitor = "+1" }),
    { description = "Monitor: Focus next monitor" }
)
hl.bind(
    "SUPER + SHIFT + comma",
    hl.dsp.window.move({ monitor = "-1" }),
    { description = "Window: Move to previous monitor" }
)
hl.bind(
    "SUPER + SHIFT + period",
    hl.dsp.window.move({ monitor = "+1" }),
    { description = "Window: Move to next monitor" }
)
hl.unbind("SUPER + ALT + M") -- default: toggle mic
hl.bind(
    "SUPER + ALT + M",
    hl.dsp.workspace.swap_monitors({ monitor1 = "eDP-1", monitor2 = "DP-1" }),
    { description = "Workspaces: Swap active workspaces across monitors" }
)

-- ##! Voice Dictation (HyprVox)
hl.bind(
    "SUPER + H",
    hl.dsp.exec_cmd("~/.local/bin/whisper-dictate"),
    { description = "Voice: Toggle AI voice dictation" }
)
hl.bind(
    "SUPER + SHIFT + H",
    hl.dsp.exec_cmd("~/.local/bin/whisper-dictate --dict"),
    { description = "Voice: Edit vocabulary and dictionary" }
)

-- ##! Battery Saver Club (Unified Power Profile Toggle)
hl.bind(
    "SUPER + ALT + P",
    hl.dsp.exec_cmd("bash ~/.config/hypr/custom/scripts/power_saver_toggle.sh"),
    { description = "Power: Toggle Battery Saver mode (blur, video wallpaper, EPP)" }
)

-- ##! Wallpaper (rofi picker, no Quickshell)
hl.unbind("CTRL + SUPER + T")
hl.bind(
    "CTRL + SUPER + T",
    hl.dsp.exec_cmd("~/.config/hypr/custom/scripts/wallpaper-picker.sh"),
    { description = "Wallpaper: Pick wallpaper" }
)
hl.unbind("CTRL + SUPER + ALT + T")
hl.bind(
    "CTRL + SUPER + ALT + T",
    hl.dsp.exec_cmd("~/.config/hypr/custom/scripts/wallpaper-picker.sh --random"),
    { description = "Wallpaper: Random wallpaper" }
)

-- ##! Clipboard Manager (Vicinae Clipboard)
hl.unbind("SUPER + V")
hl.bind(
    "SUPER + V",
    hl.dsp.exec_cmd("vicinae cmd launch clipboard:history"),
    { description = "Clipboard: Open Vicinae Clipboard Manager" }
)

-- ##! Emoji Picker (Vicinae Emoji)
hl.unbind("SUPER + period")
hl.bind(
    "SUPER + period",
    hl.dsp.exec_cmd("vicinae cmd launch core:search-emojis"),
    { description = "Emoji: Open Vicinae Emoji Picker" }
)

-- unbind some  
hl.unbind("SUPER + SUPER_L")
hl.unbind("SUPER + SUPER_R")
hl.unbind("SUPER + SUPER_L")
hl.unbind("SUPER + SUPER_R")
hl.unbind("SUPER_L")
hl.unbind("SUPER_R")
hl.unbind("SUPER + Tab");
hl.unbind("SUPER + Slash");


hl.unbind("SUPER + A");
hl.bind(
    "SUPER + A",
    hl.dsp.exec_cmd("~/.config/waybar/scripts/control-center.sh")
)

-- ##! Replacements for Quickshell binds (Quickshell is no longer used)
local scripts = "~/.config/hypr/custom/scripts"

hl.bind("SUPER + Slash", hl.dsp.exec_cmd(scripts .. "/keybinds-cheatsheet.sh"),
    { description = "Shell: Keybind cheatsheet" })
hl.unbind("SUPER + J")
hl.bind("SUPER + J", hl.dsp.exec_cmd("pkill -SIGUSR1 waybar"), { description = "Shell: Toggle bar" })
hl.unbind("CTRL + SUPER + R")
hl.bind("CTRL + SUPER + R", hl.dsp.exec_cmd("pkill -x waybar; waybar & swaync-client -R; swaync-client -rs"),
    { description = "Shell: Restart bar and notifications" })
hl.unbind("CTRL + SUPER + SHIFT + D")
hl.bind("CTRL + SUPER + SHIFT + D", hl.dsp.exec_cmd(scripts .. "/toggle-dark-mode.sh"),
    { description = "Shell: Toggle light/dark mode" })

-- volume/brightness keys with an on-screen display (swayosd); osd.sh falls
-- back to plain wpctl/brightnessctl when swayosd isn't running
local osd = scripts .. "/osd.sh"
for _, key in ipairs({ "XF86MonBrightnessUp", "XF86MonBrightnessDown", "XF86AudioRaiseVolume",
    "XF86AudioLowerVolume", "XF86AudioMute", "XF86AudioMicMute", "ALT + XF86AudioMute" }) do
    hl.unbind(key)
end
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(osd .. " bright-up"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(osd .. " bright-down"), { locked = true, repeating = true })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(osd .. " vol-up"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(osd .. " vol-down"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd(osd .. " vol-mute"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd(osd .. " mic-mute"), { locked = true })
hl.bind("ALT + XF86AudioMute", hl.dsp.exec_cmd(osd .. " mic-mute"), { locked = true })

-- Quickshell-only binds with no replacement
hl.unbind("SUPER + M")
hl.unbind("SUPER + G")
hl.unbind("SUPER + K")
hl.unbind("CTRL + SUPER + P")
hl.unbind("SHIFT + SUPER + ALT + Slash")

-- dock: show/hide (starts it if it isn't running)
hl.bind("SUPER + SHIFT + D", hl.dsp.exec_cmd("qs -c hud-dock ipc call dock toggle || qs -n -c hud-dock"),
    { description = "Shell: Toggle dock" })
