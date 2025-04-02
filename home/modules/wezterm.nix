{ pkgs, config, lib, ... }:
with lib; with builtins;

let
  cfg = config.tc.wezterm;
  shellIntegrationStr =
    if cfg.package != null then ''
      source "${cfg.package}/etc/profile.d/wezterm.sh"
    '' else "";
  padding_override.__raw = ''
    config.window_frame = {
    	border_left_width = '0',
    	border_right_width = '0',
    	border_bottom_height = '0',
    	border_top_height = '0',
    	border_left_color = 'purple',
    	border_right_color = 'purple',
    	border_bottom_color = 'purple',
    	border_top_color = 'purple',
    }

    config.window_padding = {
    	left = 0,
    	right = 0,
    	top = 0,
    	bottom = 0,
    }
  '';

  config_overrides = if cfg.window_padding.override then padding_override.__raw else "";
in
{
  options.tc.wezterm = with types;
    {
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
      window_padding.override = mkEnableOption "Override padding and frame for window config (applicable for hyprland)";
      package = mkOption {
        type = nullOr package;
        default = pkgs.wezterm;
        defaultText = literalExpression "pkgs.wezterm";
        description = "The Wezterm package to install.";
      };
      autoDarkMode = mkEnableOption "Use theme that matches appearance (auto light/dark mode)" // { default = pkgs.stdenv.isDarwin; };
      windowBackgroundOpacity = mkOption {
        type = types.number;
        description = "background opacity";
        default = 1.0;
        example = 0.7;
      };
      textBackgroundOpacity = mkOption {
        type = types.number;
        description = "text background opacity";
        default = 1.0;
        example = 0.6;
      };
      mux = mkEnableOption "use wezterm as multiplexer (ala tmux)";
    };

  config = mkIf cfg.enable {
    home.packages = if cfg.package != null then [ cfg.package ] else [ ];
    home.file = {
      ".config/wezterm/wezterm.lua".text = replaceStrings
        [
          ''"FONT_SIZE"''
          "WINDOW_DECORATIONS"
          "-- CONFIG_OVERRIDES_HERE"
          ''"AUTO_DARK_MODE"''
          ''"USE_MUX"''
          ''"WINDOW_BACKGROUND_OPACITY"''
          ''"TEXT_BACKGROUND_OPACITY"''
        ]
        [
          (toString cfg.fontsize)
          (if cfg.window_decorations.resize then "RESIZE" else "NONE")
          config_overrides
          (if cfg.autoDarkMode then "true" else "false")
          (if cfg.mux then "true" else "false")
          (toString cfg.windowBackgroundOpacity)
          (toString cfg.textBackgroundOpacity)
        ]
        (readFile ./wezterm/wezterm.lua);
    };
    programs.zsh.initExtra = shellIntegrationStr;
  };
}
