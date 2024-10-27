{ pkgs, config, lib, ... }:
with lib; with builtins;

let
  cfg = config.tc.wezterm;
  shellIntegrationStr = ''
    source "${cfg.package}/etc/profile.d/wezterm.sh"
  '';
in
{
  options.tc.wezterm = with types; {
    enable = mkEnableOption "use wezterm";
    fontsize = mkOption {
      type = types.number;
      description = "fontsize in terminal";
      default = 15.2;
    };
    window_decorations.resize = mkOption {
      type = types.bool;
      description = "enable resize window_decorations";
      default = true;
    };
    package = mkOption {
      type = types.package;
      default = pkgs.wezterm;
      defaultText = literalExpression "pkgs.wezterm";
      description = "The Wezterm package to install.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];
    home.file = {
      ".config/wezterm/wezterm.lua".text = replaceStrings
        [
          ''"FONT_SIZE"''
          "WINDOW_DECORATIONS"
        ]
        [
          (toString cfg.fontsize)
          (if cfg.window_decorations.resize then "RESIZE" else "NONE")
        ]
        (readFile ./wezterm/wezterm.lua);
    };
    programs.zsh.initExtra = shellIntegrationStr;
  };
}
