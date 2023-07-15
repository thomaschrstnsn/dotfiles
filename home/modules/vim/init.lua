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

require("luasnip/loaders/from_vscode").lazy_load()

local rt = require("rust-tools")

rt.setup({
	tools = {
		executor = require("rust-tools.executors").quickfix,
	},
})

rt.inlay_hints.set()
rt.inlay_hints.enable()
rt.runnables.runnables()

require('crates').setup()

require("lsp-format").setup {}
local on_attach = function(client)
	require("lsp-format").on_attach(client)
end
require("lspconfig").rust_analyzer.setup {
	on_attach = on_attach
}
require("lspconfig").rnix.setup {
	on_attach = on_attach
}

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

require("indent_blankline").setup {
	space_char_blankline = " ",
	show_current_context = true,
	show_current_context_start = true,
	char = '│',
	show_trailing_blankline_indent = false
}

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

-- rest-nvim
require('rest-nvim').setup()

vim.cmd "au BufRead,BufNewFile *.http set ft=http"
vim.api.nvim_create_autocmd(
  "FileType",
  { pattern = { "httpResult" }, command = [[nnoremap <buffer><silent> q :close<CR>]] }
)

-- toggleterm
-- https://github.com/akinsho/toggleterm.nvim
require("toggleterm").setup({
	open_mapping = [[\\]],
	direction = 'float',
	size = function(term)
		if term.direction == "horizontal" then
			return 15
		elseif term.direction == "vertical" then
			return vim.o.columns * 0.4
		end
	end,
})
local Terminal  = require('toggleterm.terminal').Terminal
local gitui = Terminal:new({ cmd = "$GITUI$", hidden = true, direction = "float" })

function Gitui_toggle()
  gitui:toggle()
end

function _G.set_terminal_keymaps()
  local opts = {buffer = 0}
  vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
  vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
  vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
  vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
end

-- if you only want these mappings for toggle term use term://*toggleterm#* instead
vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')


-- nvim-test
require("nvim-test").setup{
	term = "toggleterm",
	termOpts = {
		direction = 'horizontal'
	}
}

vim.keymap.set({"n", "o", "x"}, "w", "<cmd>lua require('spider').motion('w')<CR>", { desc = "Spider-w" })
vim.keymap.set({"n", "o", "x"}, "e", "<cmd>lua require('spider').motion('e')<CR>", { desc = "Spider-w" })
vim.keymap.set({"n", "o", "x"}, "b", "<cmd>lua require('spider').motion('b')<CR>", { desc = "Spider-w" })
vim.keymap.set({"n", "o", "x"}, "ge", "<cmd>lua require('spider').motion('ge')<CR>", { desc = "Spider-w" })

