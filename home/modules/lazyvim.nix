{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.lazyvim;
in
{
  options.tc.lazyvim = {
    enable = mkEnableOption "lazyvim";
  };

  config = mkIf cfg.enable {
    programs.lazyvim = {
      enable = true;
      extras = {
        lang = {
          nix.enable = true;
        };
      };
      plugins = with pkgs.vimPlugins; [
        (nvim-treesitter.withPlugins (plugins: attrValues {
          inherit (plugins)
            c_sharp
            rust
            yaml
            zig;
        }))
        crates-nvim
        oil-nvim
        rose-pine
        rustaceanvim
        nvim-spider
        undotree
        vim-tmux-navigator
      ];
      pluginsFile = {
        "editor.lua".source = ./lazy/plugins/editor.lua;
        "lsp.lua".source = ./lazy/plugins/lsp.lua;
        "oil.lua".source = ./lazy/plugins/oil.lua;
        "rose-pine.lua".source = ./lazy/plugins/rose-pine.lua;
        "rust.lua".source = ./lazy/plugins/rust.lua;
        "snacks.lua".source = ./lazy/plugins/snacks.lua;
        "spider.lua".source = ./lazy/plugins/spider.lua;
      };

      pluginsToDisable = [
        # # example - tokyonight seems to be required
        # {
        #   lazyName = "tokyonight.nvim";
        #   nixName = "tokyonight-nvim";
        # }
      ];
    };

    xdg.configFile = {
      "nvim/lua/config/keymaps.lua".source = ./lazy/config/keymaps.lua;
      "nvim/lua/config/options.lua".source = ./lazy/config/options.lua;
    };

    home.packages = with pkgs; [
      figlet
      lazygit
      lolcat
      nixpkgs-fmt
      ripgrep
      taplo
    ];

    home.shellAliases = {
      vim = "nvim";
    };
  };
}
