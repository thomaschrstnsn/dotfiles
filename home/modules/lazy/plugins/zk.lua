local MDUtil = {}
local function is_list_item(line)
	return line:match("^%s*[-*+]%s") ~= nil
end

-- Check if a line is a checkbox list item
local function is_checkbox_item(line)
	return line:match("^%s*[-*+]%s%[.%]%s") ~= nil
end

-- Toggle the current line through three states: normal -> list -> checkbox -> normal
function MDUtil.toggle_checkbox()
	local line = vim.api.nvim_get_current_line()

	-- Get the current indentation
	local indent = line:match("^%s*") or ""

	if is_checkbox_item(line) then
		-- State 3: checkbox item -> normal line (remove checkbox)
		local content = line:gsub("^%s*[-*+]%s%[.%]%s", "")
		vim.api.nvim_set_current_line(indent .. content)
	elseif is_list_item(line) then
		-- State 2: list item -> checkbox item
		local new_line = line:gsub("^(%s*)[-*+]%s", "%1- [ ] ")
		vim.api.nvim_set_current_line(new_line)
	else
		-- State 1: normal line -> list item
		local content = line:gsub("^%s*", "")
		vim.api.nvim_set_current_line(indent .. "- " .. content)
	end

	-- Move cursor to end of line
	vim.cmd("normal! $")
end

function MDUtil.increase_header()
	local line = vim.api.nvim_get_current_line()

	-- Count current header level
	local header_count = 0
	local content = line

	-- Match existing headers
	local header_prefix = line:match("^(#+)%s")
	if header_prefix then
		header_count = #header_prefix
		content = line:gsub("^#+%s*", "")
	end

	-- Max 6 header levels in markdown
	if header_count < 6 then
		local new_header = string.rep("#", header_count + 1) .. " " .. content
		vim.api.nvim_set_current_line(new_header)
	end
end

-- Decrease header level (## -> # -> normal)
function MDUtil.decrease_header()
	local line = vim.api.nvim_get_current_line()

	-- Match existing headers
	local header_prefix = line:match("^(#+)%s")
	if header_prefix then
		local header_count = #header_prefix
		local content = line:gsub("^#+%s*", "")

		if header_count > 1 then
			-- Decrease by one level
			local new_header = string.rep("#", header_count - 1) .. " " .. content
			vim.api.nvim_set_current_line(new_header)
		else
			-- Remove header completely (level 1 -> normal)
			vim.api.nvim_set_current_line(content)
		end
	end
end

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

			local dir = vim.env.ZK_NOTES_DIR or "~/zk.personal/"
			local spell_file = dir .. "/spell.en.utf8.add"

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

					-- spelling
					vim.opt_local.spellfile = vim.fn.expand(spell_file)
					-- rebuild (.add is checked in to VCS, build the binary again)
					vim.cmd("mkspell! " .. spell_file)

					vim.keymap.set("i", "<C-l>", function()
						require("zk").pick_notes(nil, { title = "Zk Insert Link" }, function(notes)
							if notes and #notes > 0 then
								local note = notes[1]
								local link = string.format("[[%s]]", note.title)

								-- Get current cursor position and line
								local row, col = unpack(vim.api.nvim_win_get_cursor(0))
								local line = vim.api.nvim_get_current_line()

								-- Check for whitespace before cursor
								local char_before = col > 0 and line:sub(col, col) or ""
								local needs_space_before = col > 0 and char_before:match("%S")

								-- Check for whitespace after cursor
								local char_after = col < #line and line:sub(col + 1, col + 1) or ""
								local needs_space_after = char_after:match("%S")

								-- print("before/after", char_before, char_after)
								-- print("need before/after", needs_space_before, needs_space_after)

								-- Build the final link with appropriate spacing
								local final_link = (needs_space_before and " " or "")
									.. link
									.. (needs_space_after and " " or "")

								-- Schedule insert mode and type the link text
								vim.schedule(function()
									vim.api.nvim_feedkeys(
										vim.api.nvim_replace_termcodes("<Right>", true, false, true),
										"n",
										false
									)
									vim.cmd("startinsert")
									vim.api.nvim_feedkeys(final_link, "n", false)
								end)
							end
						end)
					end, { buffer = true, desc = "Insert zk link" })

					vim.keymap.set(
						"v",
						"<leader>nn",
						":<C-u>'<,'>ZkNewFromTitleSelection<cr>",
						{ buffer = true, desc = "New with title from sel." }
					)
					--
					-- Visual mode mapping (mode = "x")
					vim.keymap.set("x", "`", function()
						-- Get visual selection range (line numbers are 1-based)
						local start_line = vim.fn.line("v")
						local end_line = vim.fn.line(".")

						-- Normalize order (support selecting bottom→top)
						if start_line > end_line then
							start_line, end_line = end_line, start_line
						end

						-- Insert closing fence *after* the selection
						vim.api.nvim_buf_set_lines(0, end_line, end_line, false, { "```" })
						-- Insert opening fence *before* the selection
						vim.api.nvim_buf_set_lines(0, start_line - 1, start_line - 1, false, { "```" })

						-- Place cursor after the opening ```
						vim.api.nvim_win_set_cursor(0, { start_line, 3 })
					end, {
						buffer = true,
						desc = "Surround selection with code fence",
					})

					vim.keymap.set("n", "<leader>nb", "<cmd>ZkBacklinks<CR>", { buffer = true, desc = "Zk: Backlinks" })
					vim.keymap.set("n", "<leader>nl", "<cmd>ZkLinks<CR>", { buffer = true, desc = "Zk: Links" })
					vim.keymap.set("n", "<leader>nt", "<cmd>ZkTags<CR>", { buffer = true, desc = "Zk: Tags" })
					vim.keymap.set("n", "<leader>ni", "<cmd>ZkIndex<CR>", { buffer = true, desc = "Zk: Index" })
					vim.keymap.set("n", "<leader>ng", "<cmd>ZkNotes<CR>", { buffer = true, desc = "Zk: Notes" })

					vim.keymap.set("n", "o", "o<cmd>AutolistNewBullet<cr>", { buffer = true })
					vim.keymap.set("n", "O", "O<cmd>AutolistNewBulletBefore<cr>", { buffer = true })
					vim.keymap.set("n", "<C-CR>", "<cmd>AutolistToggleCheckbox<cr><CR>", { buffer = true })
					vim.keymap.set("n", "<Tab>", function()
						MDUtil.toggle_checkbox()
					end, {
						buffer = true,
						desc = "Toggle markdown checkbox",
					})

					vim.keymap.set("n", ">", function()
						MDUtil.increase_header()
					end, { buffer = true, desc = "Increase markdown header level" })

					vim.keymap.set("n", "<", function()
						MDUtil.decrease_header()
					end, { buffer = true, desc = "Decrease markdown header level" })

					-- functions to recalculate list on edit
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
