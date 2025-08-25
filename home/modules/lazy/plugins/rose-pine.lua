return {
	{
		"rose-pine/neovim",
		name = "rose-pine",
		config = function()
			require("rose-pine").setup({
				extend_background_behind_borders = true,
				styles = {
					bold = true,
					italic = true,
					transparency = true,
				},

				highlight_groups = {
					NormalFloat = { bg = "overlay" },
					FloatBorder = { fg = "muted", bg = "surface" },
				},
			})
			vim.cmd("colorscheme rose-pine")
		end,
	},
	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = "rose-pine",
		},
	},
}
