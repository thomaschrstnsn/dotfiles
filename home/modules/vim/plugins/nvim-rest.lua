require('rest-nvim').setup()

vim.cmd "au BufRead,BufNewFile *.http set ft=http"
vim.api.nvim_create_autocmd(
	"FileType",
	{ pattern = { "httpResult" }, command = [[nnoremap <buffer><silent> q :close<CR>]] }
)
