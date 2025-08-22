return {
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				nil_ls = { formatter = { command = { "nixpkgs-fmt" } }, nix = { flake = { autoArchive = true } } },
			},
		},
	},
}
