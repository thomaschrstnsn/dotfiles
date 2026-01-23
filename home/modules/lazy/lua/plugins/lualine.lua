return {
	"nvim-lualine/lualine.nvim",
	opts = function(_, opts)
		opts.options.component_separators = ""
		opts.options.section_separators = { left = "", right = "" }

		local section_c = opts.sections.lualine_c
		section_c[#section_c] = { LazyVim.lualine.pretty_path({ length = 8 }) }

		return opts
	end,
}
