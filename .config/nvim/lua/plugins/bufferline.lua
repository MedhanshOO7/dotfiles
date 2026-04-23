return {
	"akinsho/bufferline.nvim",
	event = "VeryLazy",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		local bufferline = require("bufferline")
		local bufferline_group = vim.api.nvim_create_augroup("dynamic_bufferline_theme", { clear = true })

		local function hl_hex(name, key)
			local ok, value = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
			if ok and value and value[key] then
				return string.format("#%06x", value[key])
			end
		end

		local function first_hl_hex(groups, key)
			for _, group in ipairs(groups) do
				local value = hl_hex(group, key)
				if value then
					return value
				end
			end
		end

		local function hex_to_rgb(hex)
			if not hex then
				return nil, nil, nil
			end

			hex = hex:gsub("#", "")
			if #hex ~= 6 then
				return nil, nil, nil
			end

			return tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16)
		end

		local function blend(top, bottom, alpha)
			local tr, tg, tb = hex_to_rgb(top)
			local br, bg, bb = hex_to_rgb(bottom)
			if not (tr and tg and tb and br and bg and bb) then
				return bottom or top
			end

			local function channel(foreground, background)
				return math.floor((alpha * foreground) + ((1 - alpha) * background) + 0.5)
			end

			return string.format("#%02x%02x%02x", channel(tr, br), channel(tg, bg), channel(tb, bb))
		end

		local function apply_highlights()
			local base_bg = first_hl_hex({ "TabLineFill", "StatusLine", "NormalFloat", "Normal", "Pmenu" }, "bg")
			local normal_bg = base_bg or "NONE"
			local normal_fg = first_hl_hex({ "Normal", "StatusLine", "TabLineSel", "Title", "Identifier" }, "fg")
			local comment_fg = first_hl_hex({ "Comment", "LineNr", "NonText", "StatusLineNC" }, "fg") or normal_fg
			local accent_fg = first_hl_hex({ "Function", "Identifier", "Title", "Special" }, "fg") or normal_fg
			local inactive_bg = blend(comment_fg or normal_fg, base_bg, 0.10) or normal_bg
			local visible_bg = blend(comment_fg or normal_fg, base_bg, 0.18) or normal_bg
			local separator_fg = blend(comment_fg or normal_fg, base_bg, 0.35) or comment_fg or normal_fg

			vim.opt.showtabline = 1

			bufferline.setup({
				options = {
					mode = "buffers",
					style_preset = bufferline.style_preset.no_italic,
					separator_style = { "|", "|" },
					diagnostics = "nvim_lsp",
					custom_areas = {
						left = function()
							return {
								{
									underline = true,
								},
							}
						end,
					},
					color_icons = true,
					indicator = {
						style = "underline",
					},
					numbers = "none",
					show_buffer_close_icons = false,
					show_close_icon = false,
					always_show_bufferline = false,
					show_tab_indicators = false,
					tab_size = 18,
					max_name_length = 25,
					truncate_names = false,
					hover = {
						enabled = true,
						delay = 120,
						reveal = { "close" },
					},
					persist_buffer_sort = true,
					sort_by = "insert_after_current",
					modified_icon = "●",
					diagnostics_indicator = function(count, level)
						local icon = level:match("error") and " " or " "
						return " " .. icon .. count
					end,
					offsets = {
						{
							filetype = "neo-tree",
							text = "Explorer",
							highlight = "Directory",
							text_align = "left",
							separator = true,
						},
					},
				},
				highlights = {
					fill = {
						bg = normal_bg,
					},
					background = {
						fg = comment_fg,
						bg = inactive_bg,
					},
					buffer_visible = {
						fg = normal_fg,
						bg = visible_bg,
					},
					buffer_selected = {
						fg = normal_fg,
						bg = normal_bg,
						bold = true,
					},
					separator = {
						fg = separator_fg,
						bg = normal_bg,
					},
					separator_visible = {
						fg = separator_fg,
						bg = visible_bg,
					},
					separator_selected = {
						fg = separator_fg,
						bg = normal_bg,
					},
					indicator_selected = {
						fg = accent_fg,
						bg = normal_bg,
					},
					modified = {
						fg = comment_fg,
						bg = inactive_bg,
					},
					modified_visible = {
						fg = accent_fg,
						bg = visible_bg,
					},
					modified_selected = {
						fg = accent_fg,
						bg = normal_bg,
					},
					close_button = {
						fg = comment_fg,
						bg = inactive_bg,
					},
					close_button_visible = {
						fg = comment_fg,
						bg = visible_bg,
					},
					close_button_selected = {
						fg = accent_fg,
						bg = normal_bg,
					},
					duplicate = {
						fg = comment_fg,
						bg = inactive_bg,
						italic = false,
					},
					duplicate_visible = {
						fg = comment_fg,
						bg = visible_bg,
						italic = false,
					},
					duplicate_selected = {
						fg = normal_fg,
						bg = normal_bg,
						italic = false,
					},
					tab_separator = {
						fg = separator_fg,
						bg = inactive_bg,
					},
					tab_separator_selected = {
						fg = separator_fg,
						bg = normal_bg,
					},
				},
			})
		end

		apply_highlights()

		vim.api.nvim_create_autocmd("ColorScheme", {
			group = bufferline_group,
			pattern = "*",
			callback = function()
				apply_highlights()
				vim.schedule(apply_highlights)
			end,
		})
	end,
}
