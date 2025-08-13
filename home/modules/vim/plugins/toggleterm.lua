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
local Terminal = require('toggleterm.terminal').Terminal
local vcsTerm  = Terminal:new({
	cmd = "jj root --ignore-working-copy && jjui || lazygit",
	hidden = true,
	direction = "float"
})

function VcsTerm_toggle()
	vcsTerm:toggle()
end

function _G.set_terminal_keymaps()
	local opts = { buffer = 0 }
	vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
	vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
	vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
	vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
end

-- if you only want these mappings for toggle term use term://*toggleterm#* instead
vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')
