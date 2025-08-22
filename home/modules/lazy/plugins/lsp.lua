return {
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				nil_ls = {
					settings = {
						["nil"] = {
							formatting = {
								command = { "nixpkgs-fmt" },
							},
							nix = {
								flake = {
									autoArchive = true,
								},
							},
						},
					},
				},
			},
		},
	},
}
