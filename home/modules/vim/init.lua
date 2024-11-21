local trouble = require("trouble.sources.telescope")
local telescope = require("telescope")

-- https://github.com/adibhanna/nvim/blob/9b99eb1993e547eb2ef1fa1e0627ab37212688b4/lua/plugins/telescope.lua
local function document_symbols_for_selected(prompt_bufnr)
	local action_state = require("telescope.actions.state")
	local actions = require("telescope.actions")
	local entry = action_state.get_selected_entry()

	if entry == nil then
		print("No file selected")
		return
	end

	actions.close(prompt_bufnr)

	vim.schedule(function()
		local bufnr = vim.fn.bufadd(entry.path)
		vim.fn.bufload(bufnr)

		local params = { textDocument = vim.lsp.util.make_text_document_params(bufnr) }

		vim.lsp.buf_request(bufnr, "textDocument/documentSymbol", params, function(err, result, _, _)
			if err then
				print("Error getting document symbols: " .. vim.inspect(err))
				return
			end

			if not result or vim.tbl_isempty(result) then
				print("No symbols found")
				return
			end

			local function flatten_symbols(symbols, parent_name)
				local flattened = {}
				for _, symbol in ipairs(symbols) do
					local name = symbol.name
					if parent_name then
						name = parent_name .. "." .. name
					end
					table.insert(flattened, {
						name = name,
						kind = symbol.kind,
						range = symbol.range,
						selectionRange = symbol.selectionRange,
					})
					if symbol.children then
						local children = flatten_symbols(symbol.children, name)
						for _, child in ipairs(children) do
							table.insert(flattened, child)
						end
					end
				end
				return flattened
			end

			local flat_symbols = flatten_symbols(result)

			-- Define highlight group for symbol kind
			vim.cmd([[highlight TelescopeSymbolKind guifg=#61AFEF]])

			require("telescope.pickers").new({}, {
				prompt_title = "Document Symbols: " .. vim.fn.fnamemodify(entry.path, ":t"),
				finder = require("telescope.finders").new_table({
					results = flat_symbols,
					entry_maker = function(symbol)
						local kind = vim.lsp.protocol.SymbolKind[symbol.kind] or "Other"
						return {
							value = symbol,
							display = function(entry)
								local display_text = string.format("%-50s %s", entry.value.name, kind)
								return display_text,
									{ { { #entry.value.name + 1, #display_text }, "TelescopeSymbolKind" } }
							end,
							ordinal = symbol.name,
							filename = entry.path,
							lnum = symbol.selectionRange.start.line + 1,
							col = symbol.selectionRange.start.character + 1,
						}
					end,
				}),
				sorter = require("telescope.config").values.generic_sorter({}),
				previewer = require("telescope.config").values.qflist_previewer({}),
				attach_mappings = function(_, map)
					map("i", "<CR>", function(prompt_bufnr)
						local selection = action_state.get_selected_entry()
						actions.close(prompt_bufnr)
						vim.cmd("edit " .. selection.filename)
						vim.api.nvim_win_set_cursor(0, { selection.lnum, selection.col - 1 })
					end)
					return true
				end,
			}):find()
		end)
	end)
end

telescope.setup {
	defaults = {
		mappings = {
			i = {
				["<c-t>"] = trouble.open,
				["<c-s>"] = document_symbols_for_selected
			},
			n = {
				["<c-t>"] = trouble.open,
				["<c-s>"] = document_symbols_for_selected
			},
		},
	},
}

function diagnostic_goto(next, severity)
	local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
	severity = severity and vim.diagnostic.severity[severity] or nil
	go({ severity = severity })
end

local conform = require("conform")
function FormatBuffer()
	FormatWithOpts({ async = true, })
end

function FormatSelection()
	local opts = {
		async = true,
		range = {
			["start"] = vim.api.nvim_buf_get_mark(0, "<"),
			["end"] = vim.api.nvim_buf_get_mark(0, ">"),
		},
	}
	FormatWithOpts(opts)
end

function FormatWithOpts(opts)
	local lsp_formatting = false
	for _, c in pairs(vim.lsp.get_active_clients()) do
		if c.supports_method("textDocument/formatting") then
			lsp_formatting = true
			break
		end
	end
	if lsp_formatting then
		vim.lsp.buf.format(opts)
	else
		conform.format(opts)
	end
end

-- Fix virtual text since we are using lsp_lines
vim.diagnostic.config({
	virtual_text = false,
})

function illuminate_goto_reference(dir)
	require("illuminate")["goto_" .. dir .. "_reference"](false)
end

function illuminate_map(key, dir, buffer)
	vim.keymap.set("n", key, function()
		illuminate_goto_reference(dir)
	end, { desc = dir:sub(1, 1):upper() .. dir:sub(2) .. " Reference", buffer = buffer })
end

vim.api.nvim_create_autocmd("FileType", {
	callback = function()
		local buffer = vim.api.nvim_get_current_buf()
		illuminate_map("]]", "next", buffer)
		illuminate_map("[[", "prev", buffer)
	end,
})

-- mini.nvim https://github.com/echasnovski/mini.nvim
local ai = require('mini.ai')
ai.setup({
	n_lines = 100,
	custom_textobjects = {
		o = ai.gen_spec.treesitter({
			a = { "@block.outer", "@conditional.outer", "@loop.outer" },
			i = { "@block.inner", "@conditional.inner", "@loop.inner" },
		}, {}),
		f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }, {}),
		c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }, {}),
		a = ai.gen_spec.treesitter({
			a = { "@parameter.outer", "@argument.outer" },
			i = { "@parameter.inner", "@argument.inner" },
			{}
		})
	}
})

vim.keymap.set("n", "<leader>lr", function()
	return ":IncRename " .. vim.fn.expand("<cword>")
end, { expr = true })
