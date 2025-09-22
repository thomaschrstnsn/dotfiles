return {
	{
		"stevearc/oil.nvim",
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
			view_options = {
				show_hidden = true,
				is_always_hidden = function(name, _)
					return name == ".." or name == ".git" or name == ".jj"
				end,
			},
		},
		dependencies = { { "nvim-mini/mini.icons", opts = {} } },
		lazy = false,
	},
}
