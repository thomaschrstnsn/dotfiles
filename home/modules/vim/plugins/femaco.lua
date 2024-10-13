require("femaco").setup()

vim.api.nvim_create_user_command(
	'EditCodeBlock',
	function(_)
		require('femaco.edit').edit_code_block()
	end,
	{})
