-- hyprlang noerror false
-- You can make apps auto-start here
-- https://wiki.hyprland.org/Configuring/Keywords/#executing

-- Input method
-- hl.execonce("fcitx5")

hl.on("hyprland.start", function()
    -- Input method
    -- hl.exec_cmd("fcitx5")

    -- vicinae
    hl.exec_cmd("vicinae server --replace")

    -- fixing the keyring
    -- hl.exec_cmd("/usr/lib/pam_kwallet_init")
    -- hl.exec_cmd("kwalletd6")
    hl.exec_cmd("snappy-switcher --daemon")
    hl.exec_cmd("sh -c 'pgrep -x betterbird || betterbird'")
    -- hl.exec_once("caps-overlay -d")
    --exec-once = sh -c 'pgrep -x betterbird || betterbird'
end)
