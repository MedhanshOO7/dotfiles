return {
    "stevearc/quicker.nvim",
    event = "FileType qf",
    opts = {
        keys = {
            { ">", function() require("quicker").expand({ before = 2, after = 2, add_to_existing = true }) end, desc = "Expand context" },
            { "<", function() require("quicker").collapse() end, desc = "Collapse context" },
        },
    },
}
