return {
	"nvim-mini/mini.pairs",
	event = "VeryLazy",
	opts = function(_, opts)
		-- Get the default pairs
		opts.modes = opts.modes or { insert = true, command = false, terminal = false }

		-- Disable single quotes in Rust files
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "rust",
			callback = function()
				vim.b.minipairs_disable = false
				-- Override pairs for this buffer to exclude single quotes
				vim.b.minipairs_config = {
					modes = { insert = true, command = false, terminal = false },
					mappings = {
						["'"] = { action = "open", pair = "''", neigh_pattern = "[^\\].", register = { cr = false } },
					},
				}
				-- Simply unmap the single quote in insert mode for this buffer
				vim.keymap.set("i", "'", "'", { buffer = true })
			end,
		})

		return opts
	end,
}
