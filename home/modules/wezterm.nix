{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.wezterm;
in
{
  options.tc.wezterm = with types; {
    enable = mkEnableOption "use wezterm";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ wezterm ];
    home.file = {
      ".config/wezterm/wezterm.lua".source = ./wezterm/wezterm.lua;
    };
  };
}
