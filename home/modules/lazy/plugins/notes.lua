local dir = "~/wiki/"
return {
	-- start from here: https://linkarzu.com/posts/neovim/obsidian-to-neovim/
	-- fused with: https://mkaz.blog/working-with-vim/vimwiki/
	-- TODO: markdown-preview with wiki markdown, does not work?
	{
		"vimwiki/vimwiki",
		event = "BufEnter *.md",
		keys = { "<leader>ww", "<leader>wt", "<leader>w<leader>w" },
		init = function()
			vim.g.vimwiki_list = {
				{
					path = dir,
					syntax = "markdown",
					ext = "md",
					diary_rel_path = "journal",
				},
			}
			vim.g.vimwiki_global_ext = 0
			vim.g.vimwiki_auto_header = 1

			vim.api.nvim_create_autocmd("FileType", {
				pattern = "vimwiki",
				callback = function()
					-- not taking over - for Oil
					vim.keymap.set("n", "-", "<cmd>Oil<cr>", { buffer = true, desc = "Open Oil file-browser" })

					vim.keymap.set(
						"n",
						"<C-CR>",
						"<cmd>VimwikiToggleListItem<cr>",
						{ buffer = true, desc = "Toggle Completion" }
					)

					vim.keymap.set("n", "<F3>", "<cmd>Calendar<CR>", { desc = "Open calendar" })

					vim.keymap.set("n", "<leader>xt", function()
						Snacks.picker.grep({
							prompt = " ",
							search = "^\\s*- \\[ \\]",
							regex = true,
							live = false,
							dirs = { dir },
							finder = "grep",
							format = "file",
							show_empty = true,
							supports_live = true,
						})
					end, { buffer = true, desc = "Todos" })
				end,
			})
		end,
	},
	{
		"mattn/mattn-calendar-vim",
		commands = { "Calendar" },
	},
	{
		"MeanderingProgrammer/render-markdown.nvim",
		opts = {
			file_types = { "markdown", "vimwiki" },
			checkbox = {
				enabled = true,
				custom = {
					below33 = {
						raw = "[.]",
						rendered = "󰄗 ",
						highlight = "RenderMarkdownTodo",
						scope_highlight = nil,
					},
					below66 = {
						raw = "[o]",
						rendered = "󰘻 ",
						highlight = "RenderMarkdownTodo",
						scope_highlight = nil,
					},
					below99 = {
						raw = "[O]",
						rendered = "󰡖 ",
						highlight = "RenderMarkdownTodo",
						scope_highlight = nil,
					},
				},
			},
		},
		init = function()
			vim.treesitter.language.register("markdown", "vimwiki")
		end,
	},
	{
		"3rd/image.nvim",
		build = false, -- so that it doesn't build the rock https://github.com/3rd/image.nvim/issues/91#issuecomment-2453430239
		opts = {
			processor = "magick_cli",
			integrations = {
				markdown = {
					only_render_image_at_cursor = true,
				},
			},
		},
		init = function()
			-- https://linkarzu.com/posts/neovim/images-neovim/#tips-and-tricks
			vim.keymap.set("n", "<leader>io", function()
				local function get_image_path()
					-- Get the current line
					local line = vim.api.nvim_get_current_line()
					-- Pattern to match image path in Markdown
					local image_pattern = "%[.-%]%((.-)%)"
					-- Extract relative image path
					local _, _, image_path = string.find(line, image_pattern)

					return image_path
				end

				-- Get the image path
				local image_path = get_image_path()

				if image_path then
					-- Check if the image path starts with "http" or "https"
					if string.sub(image_path, 1, 4) == "http" then
						print("URL image, use 'gx' to open it in the default browser.")
					else
						-- Construct absolute image path
						local current_file_path = vim.fn.expand("%:p:h")
						local absolute_image_path = current_file_path .. "/" .. image_path

						-- Construct command to open image in Preview
						local command = "open -a Preview " .. vim.fn.shellescape(absolute_image_path)
						-- Execute the command
						local success = os.execute(command)

						if success then
							print("Opened image in Preview: " .. absolute_image_path)
						else
							print("Failed to open image in Preview: " .. absolute_image_path)
						end
					end
				else
					print("No image found under the cursor")
				end
			end, { desc = "(macOS) Open image under cursor in Preview" })
		end,
	},
	{
		"HakonHarnes/img-clip.nvim",
		event = "VeryLazy",
		opts = {
			default = {
				relative_to_current_file = true,
				prompt_for_file_name = false,
			},
		},
		keys = {
			{ "<leader>p", "<cmd>PasteImage<cr>", desc = "Paste image from system clipboard" },
		},
	},
}
