return {
    "epwalsh/obsidian.nvim",
    version = "*", -- recommended, use latest release instead of latest commit
    lazy = true,
    ft = "markdown",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "hrsh7th/nvim-cmp",
        "nvim-telescope/telescope.nvim",
        "nvim-treesitter/nvim-treesitter",
    },
    opts = {
        workspaces = {
            {
                name = "personal",
                path = "~/Documents/Obsidian Vault",
            },
        },
        notes_subdir = "notes",
        log_level = vim.log.levels.INFO,

        daily_notes = {
            folder = "daily_notes",
            date_format = "%Y-%m-%d",
            alias_format = "%B %-d, %Y",
            default_tags = { "daily-notes" },
            template = nil,
        },

        completion = {
            nvim_cmp = true,
            min_chars = 2,
        },

        mappings = {
            -- Overrides the 'gf' mapping to work with obsidian.nvim
            ["gf"] = {
                action = function()
                    return require("obsidian").util.gf_passthrough()
                end,
                opts = { noremap = false, expr = true, buffer = true },
            },
            -- Toggle check-boxes.
            ["<leader>ch"] = {
                action = function()
                    return require("obsidian").util.toggle_checkbox()
                end,
                opts = { buffer = true, desc = "Obsidian: Toggle Checkbox" },
            },
            -- Smart action depending on context, either follow link or toggle checkbox.
            ["<cr>"] = {
                action = function()
                    return require("obsidian").util.smart_action()
                end,
                opts = { buffer = true, expr = true },
            },
        },

        new_notes_location = "notes_subdir",

        note_id_func = function(title)
            -- Create note IDs in a Zettelkasten format with a timestamp and a suffix.
            -- In this case a title if the user provided one, otherwise empty.
            local suffix = ""
            if title ~= nil then
                -- If title is given, transform it into valid file name.
                suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
            else
                -- If title is nil, just add 4 random uppercase letters to the suffix.
                for _ = 1, 4 do
                    suffix = suffix .. string.char(math.random(65, 90))
                end
            end
            return tostring(os.time()) .. "-" .. suffix
        end,

        -- Optional, customize how note file names are generated given the ID and title.
        ---@param spec { id: string, title: string|? }
        ---@return string
        note_path_func = function(spec)
            -- This is equivalent to the default behavior.
            local path = spec.dir / tostring(spec.id)
            return path:with_suffix(".md")
        end,

        wiki_link_func = "use_alias_only",
        markdown_link_func = "use_groups_only",
        preferred_link_style = "wiki",

        -- Optional, customize the default name or prefix when pasting images via `:ObsidianPasteImg`.
        ---@return string
        image_name_func = function()
            -- Prefix image names with timestamp.
            return string.format("%s-", os.time())
        end,

        -- Optional, boolean or a function that takes a title and returns a boolean.
        -- Should we warn if a note might be a duplicate?
        disable_frontmatter = false,

        -- Optional, by default mid-sentence wiki-links are rendered with the
        -- default link highlight group.
        ui = {
            enable = false, -- Disable UI as we use render-markdown.nvim
        },

        -- Specify how to handle attachments.
        attachments = {
            -- The default folder to place images in via `:ObsidianPasteImg`.
            -- If this is a relative path it will be interpreted as relative to the vault root.
            -- You can always override this per image by passing a full path to the command, e.g. `:ObsidianPasteImg ~/pasted_img.png`.
            img_folder = "attachments", ---@type string
            -- A function that determines the text to insert in the note when pasting an image.
            -- It takes the `obsidian.Path` to the image file and the `obsidian.Vault` as arguments.
            ---@param client obsidian.Client
            ---@param path obsidian.Path
            ---@return string
            img_text_func = function(client, path)
                path = client:vault_relative_path(path) or path
                return string.format("![%s](%s)", path.name, path)
            end,
        },
    },
}
