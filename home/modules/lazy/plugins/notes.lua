return {
	-- TODO: start from here https://linkarzu.com/posts/neovim/obsidian-to-neovim/
	-- https://namoku.dev/blog/how-do-i-setup-lazyvim/
	-- https://mkaz.blog/working-with-vim/vimwiki/
	-- https://linkarzu.com/posts/neovim/images-neovim/
	{
		"vimwiki/vimwiki",
		event = "BufEnter *.md",
		keys = { "<leader>ww", "<leader>wt" },
		init = function()
			vim.g.vimwiki_list = {
				{
					path = "~/wiki/",
					syntax = "markdown",
					ext = "md",
					diary_rel_path = "journal",
				},
			}
			vim.g.vimwiki_auto_header = 1
		end,
	},
	{
		"3rd/image.nvim",
		build = false, -- so that it doesn't build the rock https://github.com/3rd/image.nvim/issues/91#issuecomment-2453430239
		opts = {
			processor = "magick_cli",
			integrations = {
				markdown = {
					only_render_image_at_cursor = true,
				},
			},
		},
	},
}
