math.randomseed(os.time())
local function greeting()
    local quotes = {
        "Work hard, stay humble.",
    }
    local idx = math.random(#quotes)
    return "󰖨  " .. quotes[idx]
end

local function apply_dashboard_gradients()
    -- Header gradient follows the active theme (cyan → accent → keyword → constant)
    local palette = require("utils.palette")
    local c = palette.colors()
    local steps = palette.gradient({ c.cyan, c.blue, c.violet, c.orange }, 6)
    for i, color in ipairs(steps) do
        vim.api.nvim_set_hl(0, "SnacksDashGrad" .. i, { fg = color, bold = true })
    end
end

-- Shared resize step for explorer width keymaps (+/> grow, -/< shrink)
local function resize_explorer(delta)
    return function()
        vim.cmd("vertical resize " .. (delta > 0 and "+" .. delta or tostring(delta)))
    end
end

return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false, -- bigfile/quickfile/dashboard must hook in before the first buffer loads
    opts = {
        animate = {
            enabled = false,
            duration = 20,
            fps = 100,
        },
        bigfile = {
            enabled = true,
            notify = true,
            size = 0.5 * 1024 * 1024, -- 512 KB threshold
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
                    cursorline = true,
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
                keys = {
                    { icon = " ", key = "f", desc = "Smart Find Files", action = ":lua Snacks.picker.smart()" },
                    { icon = " ", key = "n", desc = "New Empty Buffer", action = ":ene | startinsert" },
                    { icon = "󰵪 ", key = "g", desc = "Live Grep Workspace", action = ":lua Snacks.picker.grep()" },
                    { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.picker.recent()" },
                    { icon = "󰉋 ", key = "e", desc = "Project Explorer", action = ":lua Snacks.explorer()" },
                    { icon = "󱐌 ", key = "s", desc = "Restore Session", section = "session" },
                    {
                        icon = "󰒲 ",
                        key = "l",
                        desc = "Manage Plugins",
                        action = ":Lazy",
                        enabled = package.loaded.lazy ~= nil,
                    },
                    { icon = "󰅝 ", key = "q", desc = "Quit Editor", action = ":qa" },
                },
            },
            sections = {
                {
                    text = {
                        {
                            "   ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗\n",
                            hl = "SnacksDashGrad1",
                        },
                        {
                            "   ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║\n",
                            hl = "SnacksDashGrad2",
                        },
                        {
                            "   ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║\n",
                            hl = "SnacksDashGrad3",
                        },
                        {
                            "   ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║\n",
                            hl = "SnacksDashGrad4",
                        },
                        {
                            "   ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║\n",
                            hl = "SnacksDashGrad5",
                        },
                        {
                            "   ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝\n",
                            hl = "SnacksDashGrad6",
                        },
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
                { pane = 2, icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
                { pane = 2, icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
                {
                    pane = 2,
                    icon = " ",
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
        gh = { enabled = false }, -- prefer gh CLI directly over in-editor GitHub integration
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
            -- Colours: SnacksIndent / SnacksIndentScope / SnacksIndentChunk, set
            -- for every theme in lua/utils/theme.lua
            scope = {
                enabled = true,
                underline = false,
            },
            chunk = {
                enabled = true,
            },
        },
        input = {
            enabled = true,
            icon = " ",
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
        notifier = { enabled = false }, -- noice renders messages through nvim-notify (lua/plugins/noice.lua)
        picker = {
            enabled = true,
            ui_select = true,
            layout = {
                preset = "telescope",
            },
            sources = {
                select = {
                    layout = {
                        preset = "select",
                    },
                },
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
                    git_status = true,
                    icons = {
                        files = {
                            dir = "󱧺 ",
                            dir_open = "󰉖 ",
                        },
                    },
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
                                ["+"] = resize_explorer(4),
                                ["."] = "explorer_hidden",
                                ["-"] = resize_explorer(-4),
                                [">"] = resize_explorer(4),
                                ["<"] = resize_explorer(-4),
                                ["w"] = function()
                                    local cur_w = vim.api.nvim_win_get_width(0)
                                    local next_w = 24
                                    if cur_w <= 26 then
                                        next_w = 34
                                    elseif cur_w <= 36 then
                                        next_w = 46
                                    else
                                        next_w = 24
                                    end
                                    vim.cmd("vertical resize " .. next_w)
                                    vim.notify("Explorer Width: " .. next_w .. " columns", vim.log.levels.INFO)
                                end,
                            },
                        },
                    },
                },
            },
        },
        profiler = { enabled = false }, -- unused, no perf debugging needed currently
        quickfile = { enabled = true },
        scope = { enabled = true },
        scratch = { enabled = true },
        scroll = {
            enabled = true, -- animates <C-d>/<C-u>, mouse wheel, n/N, gg/G; auto-off for bigfiles
            animate = {
                duration = { step = 10, total = 150 },
                easing = "outQuad",
            },
        },
        statuscolumn = {
            enabled = true,
            left = { "sign", "fold" }, -- diagnostics and other signs, then fold markers
            right = { "git" }, -- gitsigns bar
            folds = { open = false, git_hl = false },
            git = { patterns = { "GitSign" } },
            refresh = 50, -- ms
        },
        words = { enabled = true },
        zen = {
            enabled = true,
            -- Improve zen mode UX with better defaults
            toggles = {
                dim = false, -- Do not dim when entering zen mode
                git_signs = false, -- Hide git signs in zen mode
                diagnostics = false, -- Hide diagnostics in zen mode
                line_number = false, -- Hide line numbers in zen mode (uses zen's own numbering)
                cursorline = false, -- Hide cursorline in zen mode
                cursorcolumn = false, -- Hide cursor column in zen mode
                colorcolumn = false, -- Hide color column in zen mode
                signcolumn = false, -- Hide sign column in zen mode
            },
            -- Better window sizing for zen mode
            win = {
                -- Width as percentage (0-1) or integer columns
                width = 0.85,
                -- Height as percentage (0-1) or integer rows
                height = 0.9,
                -- Options for the zen window
                options = {
                    -- Better wrapping for prose in zen mode
                    wrap = true,
                    linebreak = true,
                    -- Keep signcolumn hidden but maintain proper spacing
                    signcolumn = "no",
                    -- Improve typing experience in zen mode
                    breakindent = true,
                    breakindentopt = "shift:2,min:20",
                    -- Better scrolling experience
                    sidescrolloff = 5,
                },
            },
        },
    },
    init = function()
        ----------------------------------------------------------------------
        -- Transparent Snacks surfaces
        --
        -- Snacks pickers/explorer use their own highlight groups rather than
        -- relying only on NormalFloat. Keep the existing foreground/border
        -- colors, but remove the opaque backgrounds so the terminal/window
        -- transparency underneath remains visible.
        ----------------------------------------------------------------------

        local function apply_snacks_transparency()
            if vim.g.preferred_transparent ~= true then
                return
            end

            local groups = {
                -- Generic picker/container surfaces
                "SnacksPicker",
                "SnacksPickerBox",
                "SnacksPickerInput",
                "SnacksPickerList",
                "SnacksPickerPreview",

                -- Picker borders/titles/footers
                "SnacksPickerBorder",
                "SnacksPickerTitle",
                "SnacksPickerFooter",
                "SnacksPickerBoxBorder",
                "SnacksPickerBoxTitle",
                "SnacksPickerBoxFooter",
                "SnacksPickerInputBorder",
                "SnacksPickerInputTitle",
                "SnacksPickerInputFooter",
                "SnacksPickerListBorder",
                "SnacksPickerListTitle",
                "SnacksPickerListFooter",
                "SnacksPickerPreviewBorder",
                "SnacksPickerPreviewTitle",
                "SnacksPickerPreviewFooter",

                -- Snacks input style used by the current config
                "SnacksInputNormal",
                "SnacksInputBorder",
                "SnacksInputTitle",
            }

            for _, group in ipairs(groups) do
                local ok, hl = pcall(vim.api.nvim_get_hl, 0, {
                    name = group,
                    link = false,
                })

                hl = ok and hl or {}
                hl.bg = "NONE"

                pcall(vim.api.nvim_set_hl, 0, group, hl)
            end
        end

        apply_dashboard_gradients()
        apply_snacks_transparency()

        vim.api.nvim_create_autocmd("ColorScheme", {
            group = vim.api.nvim_create_augroup("snacks_dashboard_gradient_sync", { clear = true }),
            pattern = "*",
            callback = function()
                apply_dashboard_gradients()

                -- Snacks may restore its default highlights during the same
                -- ColorScheme event, so apply transparency after everything
                -- else has had a chance to run.
                vim.schedule(apply_snacks_transparency)
            end,
        })

        vim.api.nvim_create_user_command("ImageToggle", function()
            if Snacks.image and Snacks.image.doc then
                Snacks.image.doc.enabled = not Snacks.image.doc.enabled
                vim.notify(
                    Snacks.image.doc.enabled and "Hovering Image Previews ENABLED 󰋩 "
                        or "Hovering Image Previews DISABLED 󰂭 ",
                    vim.log.levels.INFO,
                    { title = "Image Previews" }
                )
            end
        end, { desc = "Toggle hovering image previews ON or OFF" })
    end,
    keys = {
        {
            "<leader><space>",
            function()
                Snacks.picker.smart()
            end,
            desc = "Smart Find Files",
        },
        {
            "<leader>e",
            function()
                Snacks.explorer()
            end,
            desc = "File Explorer",
        },
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
        {
            "<leader>ih",
            function()
                Snacks.image.hover()
            end,
            desc = "Hover Image Preview (Manual)",
        },
        {
            "<leader>ui",
            function()
                if Snacks.image and Snacks.image.doc then
                    Snacks.image.doc.enabled = not Snacks.image.doc.enabled
                    vim.notify(
                        Snacks.image.doc.enabled and "Hovering Image Previews ENABLED 󰋩 "
                            or "Hovering Image Previews DISABLED 󰂭 ",
                        vim.log.levels.INFO,
                        { title = "Image Previews" }
                    )
                end
            end,
            desc = "Toggle Hovering Image Previews",
        },
        {
            "<leader>gl",
            function()
                Snacks.lazygit()
            end,
            desc = "Lazygit (VS Code-style panel)",
        },
        {
            "<leader>gf",
            function()
                Snacks.lazygit.log_file()
            end,
            desc = "Lazygit Current File History",
        },
        {
            "<leader>gB",
            function()
                Snacks.gitbrowse()
            end,
            desc = "Open Git Permalink in Browser",
        },
        {
            "<leader>uz",
            function()
                Snacks.zen()
            end,
            desc = "Toggle Zen Mode",
        },
        {
            "<leader>.",
            function()
                Snacks.scratch()
            end,
            desc = "Toggle Scratch Buffer",
        },
        {
            "<leader>S",
            function()
                Snacks.scratch.select()
            end,
            desc = "Select Scratch Buffer",
        },
        {
            "<leader>cR",
            function()
                Snacks.rename.rename_file()
            end,
            desc = "Rename File (LSP)",
        },
        {
            "]r",
            function()
                Snacks.words.jump(1, true)
            end,
            desc = "Next LSP Word Reference",
        },
        {
            "[r",
            function()
                Snacks.words.jump(-1, true)
            end,
            desc = "Prev LSP Word Reference",
        },
    },
}
