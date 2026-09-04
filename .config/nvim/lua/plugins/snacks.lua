local function greeting()
    local hour = tonumber(os.date("%H")) or 12
    if hour < 12 then
        return "󰖨  Good morning, Medhansh"
    elseif hour < 18 then
        return "󰖙  Good afternoon, Medhansh"
    else
        return "  Good evening, Medhansh"
    end
end

local function apply_dashboard_gradients()
    vim.api.nvim_set_hl(0, "SnacksDashGrad1", { fg = "#89dceb", bold = true })
    vim.api.nvim_set_hl(0, "SnacksDashGrad2", { fg = "#89b4fa", bold = true })
    vim.api.nvim_set_hl(0, "SnacksDashGrad3", { fg = "#b4befe", bold = true })
    vim.api.nvim_set_hl(0, "SnacksDashGrad4", { fg = "#cba6f7", bold = true })
    vim.api.nvim_set_hl(0, "SnacksDashGrad5", { fg = "#f5c2e7", bold = true })
    vim.api.nvim_set_hl(0, "SnacksDashGrad6", { fg = "#fab387", bold = true })
end

return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
        animate = {
            enabled = false,
            duration = 20,
            fps = 100,
        },
        bigfile = {
            enabled = true,
            notify = true,
            size = 1.0 * 1024 * 1024, -- 1 MB threshold
            line_length = 1000, -- line length threshold for minified files
            setup = function(ctx)
                vim.b[ctx.buf].large_file = true
                vim.b[ctx.buf].bigfile = true
                vim.b[ctx.buf].minianimate_disable = true
                vim.b[ctx.buf].miniindentscope_disable = true
                pcall(vim.cmd, "NoMatchParen")
                Snacks.util.wo(0, {
                    foldmethod = "manual",
                    statuscolumn = "",
                    conceallevel = 0,
                    relativenumber = false,
                    cursorline = false,
                    list = false,
                })
                vim.schedule(function()
                    if vim.api.nvim_buf_is_valid(ctx.buf) then
                        vim.bo[ctx.buf].syntax = ""
                        vim.bo[ctx.buf].swapfile = false
                        vim.bo[ctx.buf].undofile = false
                        -- Detach all LSP clients from this large buffer
                        for _, client in ipairs(vim.lsp.get_clients({ bufnr = ctx.buf })) do
                            pcall(vim.lsp.buf_detach_client, ctx.buf, client.id)
                        end
                    end
                end)
            end,
        },
        bufdelete = { enabled = true },
        dashboard = {
            enabled = true,
            preset = {
                header = [[
   ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
   ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
   ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
   ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
   ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
   ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]],
                keys = {
                    { icon = " ", key = "f", desc = "Smart Find Files", action = ":lua Snacks.picker.smart()" },
                    { icon = "󰈔 ", key = "n", desc = "New Empty Buffer", action = ":ene | startinsert" },
                    { icon = " ", key = "g", desc = "Live Grep Workspace", action = ":lua Snacks.picker.grep()" },
                    { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.picker.recent()" },
                    { icon = "󰉋 ", key = "e", desc = "Project Explorer", action = ":lua Snacks.explorer()" },
                    { icon = "󱐌 ", key = "s", desc = "Restore Session", section = "session" },
                    { icon = "󰒲 ", key = "l", desc = "Manage Plugins", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
                    { icon = " ", key = "q", desc = "Quit Editor", action = ":qa" },
                },
            },
            sections = {
                {
                    text = {
                        { "   ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗\n", hl = "SnacksDashGrad1" },
                        { "   ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║\n", hl = "SnacksDashGrad2" },
                        { "   ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║\n", hl = "SnacksDashGrad3" },
                        { "   ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║\n", hl = "SnacksDashGrad4" },
                        { "   ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║\n", hl = "SnacksDashGrad5" },
                        { "   ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝\n", hl = "SnacksDashGrad6" },
                    },
                    align = "center",
                    padding = 1,
                },
                {
                    text = {
                        { " " .. greeting() .. " ", hl = "Function" },
                    },
                    align = "center",
                    padding = 1,
                },
                {
                    pane = 2,
                    section = "terminal",
                    cmd = vim.fn.executable("colorscript") == 1 and "colorscript -e square" or "echo ''",
                    height = 5,
                    padding = 1,
                },
                { section = "keys", gap = 1, padding = 1 },
                { pane = 2, icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
                { pane = 2, icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
                {
                    pane = 2,
                    icon = " ",
                    title = "Git Status",
                    section = "terminal",
                    enabled = function()
                        return Snacks.git.get_root() ~= nil
                    end,
                    cmd = "git status --short --branch --renames",
                    height = 5,
                    padding = 1,
                    ttl = 5 * 60,
                    indent = 3,
                },
                { section = "startup" },
            },
        },
        dim = { enabled = true },
        explorer = {
            enabled = true,
            replace_netrw = true,
            trash = true,
            replace = false,
            layout = {
                preset = "sidebar",
                preview = false,
                layout = {
                    position = "left",
                    width = 24, -- Dynamic 24-column default
                },
            },
        },
        gh = { enabled = false },
        gitbrowse = { enabled = true },
        image = {
            enabled = true,
            force = true,
            formats = { "png", "jpg", "jpeg", "gif", "bmp", "webp", "tiff", "svg", "avif" },
            doc = {
                enabled = true,
                inline = false,
                float = true,
                max_width = 60,
                max_height = 20,
            },
            convert = {
                notify = false,
                magick = {
                    default = { "{src}[0]", "-resize", "1200x800>" },
                },
            },
        },
        indent = {
            enabled = true,
            char = "│",
            animate = {
                enabled = true,
                style = "out",
                easing = "linear",
                duration = {
                    step = 20,
                    total = 250,
                },
            },
            scope = {
                enabled = true,
                underline = false,
                hl = "IblScope",
            },
            chunk = {
                enabled = true,
                hl = "IblIndent",
            },
        },
        input = {
            enabled = true,
            icon = " ",
            icon_hl = "SnacksInputIcon",
            icon_pos = "left",
            prompt_pos = "title",
            expand = true,
            win = {
                style = "input",
                border = "rounded",
                backdrop = false, -- Eliminates rectangular shadow bleeding
                position = "float",
                wo = {
                    winhighlight = "NormalFloat:SnacksInputNormal,FloatBorder:SnacksInputBorder,FloatTitle:SnacksInputTitle",
                    winblend = 0,
                },
            },
        },
        lazygit = { enabled = true },
        notifier = {
            enabled = true,
            timeout = 3000,
            width = { min = 35, max = 0.40 },
            height = { min = 1, max = 0.60 },
            margin = { top = 1, right = 1, bottom = 0 },
            padding = true,
            gap = 1,
            sort = { "level", "added" },
            level = vim.log.levels.TRACE,
            style = "minimal",
            top_down = true, -- top-to-bottom on the right side
        },
        picker = {
            enabled = true,
            ui_select = true,
            layout = {
                preset = "telescope",
            },
            sources = {
                files = {
                    hidden = true,
                },
                grep = {
                    hidden = true,
                },
                smart = {
                    hidden = true,
                },
                explorer = {
                    layout = {
                        preset = "sidebar",
                        preview = false,
                        layout = {
                            position = "left",
                            width = 24, -- 24 columns compact default
                        },
                    },
                    win = {
                        list = {
                            keys = {
                                ["<CR>"] = "confirm",
                                ["<S-CR>"] = "pick_win",
                                ["<C-t>"] = "tab",
                                ["<C-v>"] = "vsplit",
                                ["<C-s>"] = "split",
                                ["%"] = "explorer_add",
                                ["a"] = "explorer_add",
                                ["d"] = "explorer_del",
                                ["r"] = "explorer_rename",
                                ["c"] = "explorer_copy",
                                ["m"] = "explorer_move",
                                -- Dynamic interactive width resizing inside explorer
                                ["+"] = function() vim.cmd("vertical resize +4") end,
                                ["-"] = function() vim.cmd("vertical resize -4") end,
                                [">"] = function() vim.cmd("vertical resize +4") end,
                                ["<"] = function() vim.cmd("vertical resize -4") end,
                                ["w"] = function()
                                    local cur_w = vim.api.nvim_win_get_width(0)
                                    local next_w = 24
                                    if cur_w <= 26 then next_w = 34
                                    elseif cur_w <= 36 then next_w = 46
                                    else next_w = 24 end
                                    vim.cmd("vertical resize " .. next_w)
                                    vim.notify("Explorer Width: " .. next_w .. " columns", vim.log.levels.INFO)
                                end,
                            },
                        },
                    },
                },
            },
        },
        profiler = { enabled = false },
        quickfile = { enabled = true },
        scope = { enabled = true },
        scratch = { enabled = true },
        scroll = { enabled = false }, -- cinnamon.nvim handles smooth scrolling
        statuscolumn = { enabled = true },
        words = { enabled = true },
        zen = { enabled = true },
    },
    init = function()
        apply_dashboard_gradients()

        vim.api.nvim_create_autocmd("ColorScheme", {
            group = vim.api.nvim_create_augroup("snacks_dashboard_gradient_sync", { clear = true }),
            pattern = "*",
            callback = apply_dashboard_gradients,
        })

        vim.api.nvim_create_autocmd("User", {
            pattern = "OilActionsPost",
            callback = function(event)
                if event.data and event.data.actions and event.data.actions[1] and event.data.actions[1].type == "move" then
                    Snacks.rename.on_rename_file(event.data.actions[1].src_url, event.data.actions[1].dest_url)
                end
            end,
        })
        vim.api.nvim_create_user_command("ImageToggle", function()
            if Snacks.image and Snacks.image.doc then
                Snacks.image.doc.enabled = not Snacks.image.doc.enabled
                vim.notify(
                    Snacks.image.doc.enabled and "Hovering Image Previews ENABLED 󰋩 " or "Hovering Image Previews DISABLED 󰂭 ",
                    vim.log.levels.INFO,
                    { title = "Image Previews" }
                )
            end
        end, { desc = "Toggle hovering image previews ON or OFF" })
    end,
    keys = {
        { "<leader><space>", function() Snacks.picker.smart() end, desc = "Smart Find Files" },
        { "<leader>e", function() Snacks.explorer() end, desc = "File Explorer" },
        {
            "<leader>si",
            function()
                Snacks.picker.files({
                    prompt = " Images ",
                    glob = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.bmp", "*.svg", "*.avif" },
                    layout = "image",
                })
            end,
            desc = "Browse Images (Floating Preview)",
        },
        { "<leader>ih", function() Snacks.image.hover() end, desc = "Hover Image Preview (Manual)" },
        {
            "<leader>ui",
            function()
                if Snacks.image and Snacks.image.doc then
                    Snacks.image.doc.enabled = not Snacks.image.doc.enabled
                    vim.notify(
                        Snacks.image.doc.enabled and "Hovering Image Previews ENABLED 󰋩 " or "Hovering Image Previews DISABLED 󰂭 ",
                        vim.log.levels.INFO,
                        { title = "Image Previews" }
                    )
                end
            end,
            desc = "Toggle Hovering Image Previews",
        },
        { "<leader>gl", function() Snacks.lazygit() end, desc = "Lazygit (VS Code-style panel)" },
        { "<leader>gf", function() Snacks.lazygit.log_file() end, desc = "Lazygit Current File History" },
        { "<leader>gB", function() Snacks.gitbrowse() end, desc = "Open Git Permalink in Browser" },
        { "<leader>z", function() Snacks.zen() end, desc = "Toggle Zen Mode" },
        { "<leader>uz", function() Snacks.zen() end, desc = "Toggle Zen Mode" },
        { "<leader>.", function() Snacks.scratch() end, desc = "Toggle Scratch Buffer" },
        { "<leader>S", function() Snacks.scratch.select() end, desc = "Select Scratch Buffer" },
        { "<leader>cR", function() Snacks.rename.rename_file() end, desc = "Rename File (LSP)" },
        { "]r", function() Snacks.words.jump(1, true) end, desc = "Next LSP Word Reference" },
        { "[r", function() Snacks.words.jump(-1, true) end, desc = "Prev LSP Word Reference" },
        { "<leader>un", "<cmd>Noice history<cr>", desc = "Notification History" },
    },
}
