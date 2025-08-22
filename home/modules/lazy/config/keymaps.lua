vim.keymap.del("n", "<leader>wd")

local map = vim.keymap.set

map("n", "<leader>w", "<cmd>w<cr><esc>", { desc = "Save File" })
map("n", "-", "<cmd>Oil<cr>", { desc = "Save File" })
map("n", "H", function()
	vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "Toggle inlay hints" })
