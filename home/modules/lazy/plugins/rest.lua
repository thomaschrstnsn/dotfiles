return {
	{
		"mistweaverco/kulala.nvim",
		ft = "http",
		keys = {
			{ "<S-CR>", "<cmd>lua require('kulala').run()<cr>", desc = "Send the request", ft = "http" },
		},
		opts = {},
	},
}
