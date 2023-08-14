{ pkgs, config, lib, ... }:
with lib; with builtins;

let
  cfg = config.tc.wezterm;
in
{
  options.tc.wezterm = with types; {
    enable = mkEnableOption "use wezterm";
    fontsize = mkOption {
      type = types.number;
      description = "fontsize in terminal";
      default = 15;
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ wezterm ];
    home.file = {
      ".config/wezterm/wezterm.lua".text = replaceStrings
        [ ''"FONTSIZE"'' ]
        [ (toString cfg.fontsize) ]
        (readFile ./wezterm/wezterm.lua);
    };
  };
}
