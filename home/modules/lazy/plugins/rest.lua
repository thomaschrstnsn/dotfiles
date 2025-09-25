return {
	{
		"mistweaverco/kulala.nvim",
		ft = "http",
		keys = {
			{ "<S-CR>", "<cmd>lua require('kulala').run()<cr>", desc = "Send the request", ft = "http" },
		},
		opts = {
			ui = {
				max_response_size = 10 * 1024 * 1024, -- 10 MB
			},
		},
	},
}
