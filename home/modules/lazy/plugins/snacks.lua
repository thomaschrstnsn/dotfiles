return {
	{
		"folke/snacks.nvim",
		keys = {
			{ "<leader>,", function() Snacks.picker.buffers({ current = false, sort_lastused = true }) end, desc = "Buffers" },
		},
	},
}
