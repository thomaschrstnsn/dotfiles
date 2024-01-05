local trouble = require("trouble.providers.telescope")
local telescope = require("telescope")

telescope.setup {
	defaults = {
		mappings = {
			i = { ["<c-t>"] = trouble.open_with_trouble },
			n = { ["<c-t>"] = trouble.open_with_trouble },
		},
	},
}

function PrevError()
	require("lspsaga.diagnostic"):goto_prev({ severity = vim.diagnostic.severity.ERROR })
end

function NextError()
	require("lspsaga.diagnostic"):goto_next({ severity = vim.diagnostic.severity.ERROR })
end

function FormatSelection()
	vim.lsp.buf.format({
		async = true,
		range = {
			["start"] = vim.api.nvim_buf_get_mark(0, "<"),
			["end"] = vim.api.nvim_buf_get_mark(0, ">"),
		}
	})
end

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', {
	clear = true
})
vim.api.nvim_create_autocmd('TextYankPost', {
	callback = function()
		vim.highlight.on_yank()
	end,
	group = highlight_group,
	pattern = '*'
})

-- Fix virtual text since we are using lsp_lines
vim.diagnostic.config({
	virtual_text = false,
})

-- barbar play nice with nvim-tree
local nvim_tree_events = require('nvim-tree.events')
local bufferline_api = require('bufferline.api')

local function get_tree_size()
	return require 'nvim-tree.view'.View.width
end

nvim_tree_events.subscribe('TreeOpen', function()
	bufferline_api.set_offset(get_tree_size())
end)

nvim_tree_events.subscribe('Resize', function()
	bufferline_api.set_offset(get_tree_size())
end)

nvim_tree_events.subscribe('TreeClose', function()
	bufferline_api.set_offset(0)
end)

function illuminate_map(key, dir, buffer)
	vim.keymap.set("n", key, function()
		require("illuminate")["goto_" .. dir .. "_reference"](false)
	end, { desc = dir:sub(1, 1):upper() .. dir:sub(2) .. " Reference", buffer = buffer })
end

illuminate_map("]]", "next")
illuminate_map("[[", "prev")

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
	n_lines = 500,
	custom_textobjects = {
		o = ai.gen_spec.treesitter({
			a = { "@block.outer", "@conditional.outer", "@loop.outer" },
			i = { "@block.inner", "@conditional.inner", "@loop.inner" },
		}, {}),
		f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }, {}),
		c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }, {}),
		a = ai.gen_spec.treesitter({ a = "@parameter.outer", i = "@parameter.inner" }, {})
	}
})
