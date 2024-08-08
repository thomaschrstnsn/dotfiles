local persistenceGroup = vim.api.nvim_create_augroup("Persistence", { clear = true })
local home = vim.fn.expand "~"
local disabled_dirs = {
	home,
	home .. "/Downloads",
	"/private/tmp",
}

-- disable persistence for certain directories
vim.api.nvim_create_autocmd({ "VimEnter" }, {
	group = persistenceGroup,
	callback = function()
		local cwd = vim.fn.getcwd()
		for _, path in pairs(disabled_dirs) do
			if path == cwd then
				require("persistence").stop()
				return
			end
		end
		if (vim.fn.argc() == 0 or (vim.fn.argc() == 1 and vim.v.argv[2] == ".")) and not vim.g.started_with_stdin then
			require("persistence").load()
		else
			require("persistence").stop()
		end
	end,
	nested = true,
})
