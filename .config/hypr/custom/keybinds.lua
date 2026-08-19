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
hl.bind("SUPER + SHIFT + T", hl.dsp.global("quickshell:regionOcr"))
hl.bind("SUPER + SHIFT + Y", hl.dsp.global("quickshell:screenTranslate"))

-- recording
hl.unbind("SUPER + SHIFT + R")
hl.bind(
    "SUPER + SHIFT + R",
    hl.dsp.exec_cmd("~/.config/quickshell/$qsConfig/scripts/videos/record.sh --fullscreen --sound"),
    { locked = true }
)
hl.unbind("SUPER + SHIFT + ALT + R")
hl.bind(
    "SUPER + SHIFT + ALT + R",
    hl.dsp.exec_cmd("~/.config/quickshell/ii/scripts/videos/record.sh --sound"),
    { locked = true }
)

-- Obsidian
hl.unbind("SUPER + O")
hl.bind("SUPER + O", hl.dsp.exec_cmd("obsidian"))

-- sidebars
hl.unbind("SUPER + A")
hl.bind("SUPER + A", hl.dsp.global("quickshell:sidebarRightToggle")) -- Toggle right sidebar
hl.unbind("SUPER + Q")
hl.bind("SUPER + Q", hl.dsp.global("quickshell:sidebarLeftToggle"))

-- hyprltm-net
hl.unbind("SUPER + N")
hl.bind("SUPER + N", hl.dsp.exec_cmd("/home/medhansh/.local/bin/hyprltm-net"))

-- rofi
hl.bind("SUPER + SPACE", hl.dsp.exec_cmd(".config/rofi/launchers/type-3/launcher.sh"))

-- PredatorSense Key (Acer Predator Key & Super+P shortcut)
local predator_gui_cmd = "/home/medhansh/builds/nekro-sense/tools/nekroctl-gui-rs/target/release/nekroctl-gui-rs"
hl.bind("XF86Launch1", hl.dsp.exec_cmd(predator_gui_cmd))
hl.bind("XF86LaunchA", hl.dsp.exec_cmd(predator_gui_cmd))
hl.bind("XF86Tools", hl.dsp.exec_cmd(predator_gui_cmd))
hl.bind("XF86Presentation", hl.dsp.exec_cmd(predator_gui_cmd))
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
hl.bind("SUPER + SHIFT + V", hl.dsp.exec_cmd([[pavucontrol]]))
hl.bind("SUPER + SHIFT + U", hl.dsp.exec_cmd([[~/.local/bin/toggle-audio]]))

hl.unbind("SUPER + SHIFT + S")

hl.bind("SUPER + SHIFT + S",
    hl.dsp.exec_cmd("bash $HOME/.config/hypr/custom/scripts/screenshot.sh"))

hl.bind("ALT + F4", hl.dsp.global("quickshell:sessionToggle"), { description = "Shell: Toggle session menu" })

-- ##! Multi-Monitor Management
hl.bind("SUPER + comma", hl.dsp.exec_cmd("hyprctl dispatch focusmonitor -1"), { description = "Monitor: Focus previous monitor" })
hl.bind("SUPER + period", hl.dsp.exec_cmd("hyprctl dispatch focusmonitor +1"), { description = "Monitor: Focus next monitor" })
hl.bind("SUPER + SHIFT + comma", hl.dsp.exec_cmd("hyprctl dispatch movewindowmon -1"), { description = "Window: Move to previous monitor" })
hl.bind("SUPER + SHIFT + period", hl.dsp.exec_cmd("hyprctl dispatch movewindowmon +1"), { description = "Window: Move to next monitor" })
hl.bind("SUPER + ALT + M", hl.dsp.exec_cmd("hyprctl dispatch swapactiveworkspaces eDP-1 HDMI-A-1"), { description = "Workspaces: Swap active workspaces across monitors" })



