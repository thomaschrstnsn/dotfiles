local map = vim.keymap.set

return {
	"ThePrimeagen/99",
	commit = "4d229141546290746c82ac90f5afc2786865b5f3",
	config = function()
		local _99 = require("99")
		_99.setup({
			provider = _99.Providers.ClaudeCodeProvider,
		})

		map("n", "<leader>9s", _99.search, { desc = "99: search" })
		map("v", "<leader>9v", _99.visual, { desc = "99: visual replace" })
		map("n", "<leader>9x", _99.stop_all_requests, { desc = "99: stop requests" })
	end,
}
