-- Configure diagnostics after LazyVim loads
vim.diagnostic.config({
	float = {
		border = "rounded",
		source = "always",
		header = "",
		prefix = "",
		focusable = false,
	},
})

