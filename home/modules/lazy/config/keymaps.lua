vim.keymap.del("n", "<leader>wd")

local map = vim.keymap.set

map("n", "<leader>w", "<cmd>w<cr><esc>", { desc = "Save File" })
map("n", "-", "<cmd>Oil<cr>", { desc = "Save File" })
