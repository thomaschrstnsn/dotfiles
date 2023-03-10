require("noice").setup({
	lsp = {
		-- override markdown rendering so that **cmp** and other plugins use **Treesitter**
		override = {
			["vim.lsp.util.convert_input_to_markdown_lines"] = true,
			["vim.lsp.util.stylize_markdown"] = true,
			["cmp.entry.get_documentation"] = true
		}
	},
	-- you can enable a preset for easier configuration
	presets = {
		bottom_search = true, -- use a classic bottom cmdline for search
		command_palette = true, -- position the cmdline and popupmenu together
		long_message_to_split = true, -- long messages will be sent to a split
		inc_rename = false, -- enables an input dialog for inc-rename.nvim
		lsp_doc_border = false -- add a border to hover docs and signature help
	}
})
require("telescope").load_extension("noice")

local __which_key = require('which-key')

__which_key.setup {
	['show_help'] = true,
	['window'] = {
		['border'] = 'single'
	}
}


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

-- nvim-tree is also there in modified buffers so this function filter it out
local modifiedBufs = function(bufs)
	local t = 0
	for k, v in pairs(bufs) do
		if v.name:match("NvimTree_") == nil then
			t = t + 1
		end
	end
	return t
end

vim.api.nvim_create_autocmd("BufEnter", {
	nested = true,
	callback = function()
		if #vim.api.nvim_list_wins() == 1 and vim.api.nvim_buf_get_name(0):match("NvimTree_") ~= nil and
			modifiedBufs(vim.fn.getbufinfo({
				bufmodified = 1
			})) == 0 then
			vim.cmd "quit"
		end
	end
})

-- mini.nvim https://github.com/echasnovski/mini.nvim
require('mini.indentscope').setup()
require('mini.surround').setup()
require('mini.jump').setup()

local db = require('dashboard')
db.custom_center = { {
	icon = '  ',
	desc = 'Recently latest session                  ',
	shortcut = 'SPC s l',
	action = 'SessionLoad'
}, {
	icon = '  ',
	desc = 'Recently opened files                   ',
	action = 'DashboardFindHistory',
	shortcut = 'SPC f h'
}, {
	icon = '  ',
	desc = 'Find  File                              ',
	action = 'Telescope find_files find_command=rg,--hidden,--files',
	shortcut = 'SPC f f'
}, {
	icon = '  ',
	desc = 'Find  word                              ',
	action = 'Telescope live_grep',
	shortcut = 'SPC f s'
} }

require("auto-session").setup {
	log_level = "error"
}

require("luasnip/loaders/from_vscode").lazy_load()

local rt = require("rust-tools")

rt.setup({
	server = {
		on_attach = function(_, bufnr)
			-- Hover actions
			vim.keymap.set("n", "gh", rt.hover_actions.hover_actions, {
				buffer = bufnr
			})
			-- Code action groups
			vim.keymap.set("n", "<Leader>.", rt.code_action_group.code_action_group, {
				buffer = bufnr
			})
		end
	}
})

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
	open_mapping = [[<c-.>]],
	direction = 'float'
})
local Terminal  = require('toggleterm.terminal').Terminal
local lazygit = Terminal:new({ cmd = "lazygit", hidden = true, direction = "float" })

function Lazygit_toggle()
  lazygit:toggle()
end
