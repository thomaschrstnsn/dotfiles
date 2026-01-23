return {
	{
		"neovim/nvim-lspconfig",
		opts = {
			inlay_hints = {
				enabled = false, -- Disable inlay hints by default
			},
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
