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
        undotree
        vim-tmux-navigator
      ];
      pluginsFile."editor.lua".source = ./lazy/editor.lua;
    };

    home.packages = with pkgs; [
      ripgrep
      taplo
      nixpkgs-fmt
    ];
  };
}
