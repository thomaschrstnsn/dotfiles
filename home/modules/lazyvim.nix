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
        crates-nvim
        oil-nvim
        rose-pine
        rustaceanvim
        undotree
        vim-tmux-navigator
      ];
      pluginsFile = {
        "editor.lua".source = ./lazy/plugins/editor.lua;
        "oil.lua".source = ./lazy/plugins/oil.lua;
        "rose-pine.lua".source = ./lazy/plugins/rose-pine.lua;
        "rust.lua".source = ./lazy/plugins/rust.lua;
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
    };

    home.packages = with pkgs; [
      ripgrep
      taplo
      nixpkgs-fmt
    ];

    home.shellAliases = {
      vim = "nvim";
    };
  };
}
