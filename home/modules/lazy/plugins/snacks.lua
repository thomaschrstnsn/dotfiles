return {
	{
		"folke/snacks.nvim",
		opts = {
			dashboard = {
				preset = {
					pick = function(cmd, opts)
						return LazyVim.pick(cmd, opts)()
					end,
					header = [[ ]],
				},

				sections = {
					{
						section = "terminal",
						cmd = "figlet -f univers -w 90 neovim | lolcat",
						height = 10,
						width = 80,
						padding = 1,
						align = "center",
					},
					{ section = "keys", gap = 1, padding = 1, width = 90 },
					{ section = "startup" },
				},
			},
		},

		keys = {
			{
				"<leader>,",
				function()
					Snacks.picker.buffers({ current = false, sort_lastused = true })
				end,
				desc = "Buffers",
			},
		},
	},
}
