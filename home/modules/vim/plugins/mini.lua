-- mini.nvim https://github.com/echasnovski/mini.nvim
require('mini.indentscope').setup()
local ai = require('mini.ai')
ai.setup({
	n_lines = 500,
	custom_textobjects = {
		o = ai.gen_spec.treesitter({
			a = { "@block.outer", "@conditional.outer", "@loop.outer" },
			i = { "@block.inner", "@conditional.inner", "@loop.inner" },
		}, {}),
		f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }, {}),
		c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }, {}),
		a = ai.gen_spec.treesitter({ a = "@parameter.outer", i = "@parameter.inner" }, {})
	}
})
-- not yet in the nix pkg: require('mini.splitjoin').setup()
