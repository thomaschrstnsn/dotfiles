return {
	{
		'stevearc/oil.nvim',
		---@module 'oil'
		---@type oil.SetupOpts
		opts = {
			keymaps = {
				["<C-h>"] = false,
				["<C-l>"] = false,
				["q"] = { "actions.close", mode = "n" },
			},
			skip_confirm_for_simple_edits = true,
			delete_to_trash = true,
		},
		-- Optional dependencies
		dependencies = { { "echasnovski/mini.icons", opts = {} } },
		-- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
		-- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
		lazy = false,
		keys = { { "n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" } }, },
	},
}
