return {
    "rmagatti/auto-session",
    lazy = false,
    config = function()
        local auto_session = require("auto-session")

        auto_session.setup({
            auto_restore = false,
            auto_save = true,
            auto_create = true,
            suppressed_dirs = { "~/", "~/Dev/", "~/Downloads", "~/Documents", "~/Desktop/" },
        })
    end,
}
