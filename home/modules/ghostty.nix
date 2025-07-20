{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.ghostty;
in
{
  options.tc.ghostty = with types; {
    enable = mkEnableOption "ghostty (terminal emulator)";

    fontsize = mkOption {
      type = number;
      description = "fontsize in terminal";
      default = 15.2;
    };

    package = mkOption {
      type = nullOr package;
      default = pkgs.ghostty;
      defaultText = literalExpression "pkgs.ghostty";
      description = "The ghostty package to install.";
    };

    windowBackgroundOpacity = mkOption {
      type = number;
      description = "background opacity";
      default = 1.0;
      example = 0.7;
    };

    lightAndDarkMode.enable = mkEnableOption "Support both light and dark mode" // { default = true; };

    shaders = mkEnableOption "custom sharders" // { default = true; };
  };

  config = mkIf cfg.enable {
    programs.ghostty = {
      enable = true;
      package = cfg.package;
      installBatSyntax = cfg.package != null;
      settings = mkMerge [{
        background-blur = true;
        background-opacity = cfg.windowBackgroundOpacity;
        cursor-style-blink = true;
        font-size = cfg.fontsize;
        initial-window = true;
        macos-icon = "retro";
        macos-titlebar-style = "hidden";
        macos-window-shadow = false;
        minimum-contrast = 1.1;
        mouse-hide-while-typing = true;
        app-notifications = "no-clipboard-copy";
        theme =
          if cfg.lightAndDarkMode.enable
          then "light:rose-pine-dawn,dark:rose-pine"
          else "rose-pine";
        window-decoration = if pkgs.stdenv.isDarwin then "auto" else "none"; # needs to be auto on macos for rounded corners
      }
        (mkIf cfg.shaders {
          custom-shader = "${./ghostty/shaders/cursor_blaze.glsl}";
        })];
    };
  };
}
