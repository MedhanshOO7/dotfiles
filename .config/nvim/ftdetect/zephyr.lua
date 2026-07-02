-- Zephyr / nRF Connect SDK file type detection
vim.filetype.add({
    extension = {
        overlay = "dts",       -- Device Tree overlays
        dts = "dts",           -- Device Tree source
        dtsi = "dts",          -- Device Tree include
        conf = function(path)
            -- Zephyr .conf files (prj.conf, boards/*.conf) are Kconfig fragments
            if path:match("prj%.conf") or path:match("boards/") then
                return "kconfig"
            end
            return "conf"
        end,
    },
    filename = {
        ["Kconfig"] = "kconfig",
        ["Kconfig.zephyr"] = "kconfig",
        ["Kconfig.defconfig"] = "kconfig",
    },
    pattern = {
        ["Kconfig.*"] = "kconfig",
    },
})
