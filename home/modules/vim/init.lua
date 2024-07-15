local trouble = require("trouble.sources.telescope")
local telescope = require("telescope")

telescope.setup {
	defaults = {
		mappings = {
			i = { ["<c-t>"] = trouble.open },
			n = { ["<c-t>"] = trouble.open },
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
