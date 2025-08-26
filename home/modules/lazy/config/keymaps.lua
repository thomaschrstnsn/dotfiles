vim.keymap.del("n", "<leader>wd")

local map = vim.keymap.set

map("n", "<leader>w", "<cmd>w<cr><esc>", { desc = "Save File" })
map("n", "-", "<cmd>Oil<cr>", { desc = "Open Oil file-browser" })
map("n", "H", function()
	vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "Toggle inlay hints" })

map("n", "<leader>/", function()
	Snacks.picker.lines()
end, { desc = "Search lines in buffer" })

map("n", '<leader>"', "<C-W>s", { desc = "Split window below" })
map("n", "<leader>%", "<C-W>v", { desc = "Split window right" })

map("n", "<leader>co", "<cmd>Trouble symbols toggle focus=true<cr>", { desc = "Trouble symbols outline" })
map(
	"n",
	"<leader>cL",
	"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
	{ desc = "Trouble references hover" }
)
