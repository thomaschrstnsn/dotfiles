local dir = "~/zk.personal/"
return {
	-- start from here: https://linkarzu.com/posts/neovim/obsidian-to-neovim/
	-- fused with: https://mkaz.blog/working-with-vim/vimwiki/
	-- before ultimately landing on: zk (https://www.youtube.com/watch?v=UzhZb7e4l4Y)
	{
		"zk-org/zk-nvim",
		config = function()
			require("zk").setup({
				picker = "snacks_picker",
				picker_options = {
					snacks_picker = {
						layout = {
							preset = "ivy",
						},
					},
				},
			})
		end,
	},
	{
		"gaoDean/autolist.nvim",
		ft = {
			"markdown",
			"text",
			"tex",
			"plaintex",
			"norg",
		},
		config = function()
			require("autolist").setup()

			local todo_picker_config = {
				prompt = " ",
				search = "^\\s*- \\[ \\]",
				regex = true,
				live = false,
				dirs = { dir },
				finder = "grep",
				format = "file",
				show_empty = true,
				supports_live = true,
			}

			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "markdown", "text", "tex", "plaintex", "norg" },
				callback = function()
					vim.keymap.set("i", "<tab>", "<cmd>AutolistTab<cr>", { buffer = true })
					vim.keymap.set("i", "<s-tab>", "<cmd>AutolistShiftTab<cr>", { buffer = true })
					vim.keymap.set("i", "<CR>", "<CR><cmd>AutolistNewBullet<cr>", { buffer = true })

					vim.keymap.set("i", "<C-l>", "<cmd>ZkInsertLink<cr>", { buffer = true })

					vim.keymap.set("n", "o", "o<cmd>AutolistNewBullet<cr>", { buffer = true })
					vim.keymap.set("n", "O", "O<cmd>AutolistNewBulletBefore<cr>", { buffer = true })
					vim.keymap.set("n", "<C-CR>", "<cmd>AutolistToggleCheckbox<cr><CR>", { buffer = true })

					-- functions to recalculate list on edit
					vim.keymap.set("n", ">>", ">><cmd>AutolistRecalculate<cr>", { buffer = true })
					vim.keymap.set("n", "<<", "<<<cmd>AutolistRecalculate<cr>", { buffer = true })
					vim.keymap.set("n", "dd", "dd<cmd>AutolistRecalculate<cr>", { buffer = true })
					vim.keymap.set("v", "d", "d<cmd>AutolistRecalculate<cr>", { buffer = true })

					vim.keymap.set("n", "<leader>st", function()
						Snacks.picker.grep(todo_picker_config)
					end, { desc = "Todos", buffer = true })

					vim.keymap.set("n", "<leader>xt", function()
						local options = vim.tbl_extend("force", todo_picker_config, {
							hidden = true,
							-- When the picker is ready, open its list in Trouble
							on_show = function(picker)
								-- If your Trouble version supports passing the picker, use:
								local ok, src = pcall(require, "trouble.sources.snacks")
								if ok then
									-- Works whether open() grabs the current Snacks session,
									-- or (if supported) accepts a picker argument.
									-- Try with picker first; fall back to global if needed.
									if type(src.open) == "function" then
										local ok2 = pcall(src.open, picker)
										if not ok2 then
											pcall(src.open)
										end
									end
								end
							end,
						})
						Snacks.picker.grep(options)
					end, { desc = "Trouble Todos", buffer = true })

					vim.diagnostic.enable(false)
				end,
			})
		end,
	},
	{
		"MeanderingProgrammer/render-markdown.nvim",
		opts = {
			file_types = { "markdown", "vimwiki" },
			heading = {
				enabled = true,
				icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
			},
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
