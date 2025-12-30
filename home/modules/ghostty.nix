{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.ghostty;

  shaders = {
    cursor_blaze = ./ghostty/shaders/cursor_blaze.glsl;
    cursor_blaze_tapered = ./ghostty/shaders/cursor_blaze_tapered.glsl;
    mnoise = ./ghostty/shaders/mnoise.glsl;
    underwater = ./ghostty/shaders/underwater.glsl;
    underwater_moving = ./ghostty/shaders/underwater_moving.glsl;
  };
in
{
  options.tc.ghostty = with types; {
    enable = mkEnableOption "ghostty (terminal emulator)";

    font = {
      size = mkOption {
        type = number;
        description = "fontsize in terminal";
        default = 15.2;
      };
      family = mkOption {
        type = nullOr str;
        description = "font-family in terminal";
        default = null;
      };
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

    shaders = mkOption {
      type = listOf (enum [ "cursor_blaze" "cursor_blaze_tapered" "mnoise" "underwater" "underwater_moving" ]);
      description = "shaders to enable";
      default = [ "cursor_blaze_tapered" "underwater" "mnoise" ];
    };

    maximized = mkEnableOption "start maximized" // { default = true; };
  };

  config = mkIf cfg.enable {
    programs.ghostty = {
      enable = true;
      inherit (cfg) package;
      installBatSyntax = cfg.package != null;
      settings = mkMerge [
        {
          keybind = [
            # "shift+enter=csi:13;2u"
            "ctrl+enter=unbind" # fullscreen on linux
          ];
          background-blur = true;
          background-opacity = cfg.windowBackgroundOpacity;
          cursor-style-blink = true;
          font-size = cfg.font.size;
          initial-window = true;
          maximize = cfg.maximized;
          macos-titlebar-style = "hidden";
          macos-window-shadow = false;
          minimum-contrast = 1.1;
          mouse-hide-while-typing = true;
          app-notifications = "no-clipboard-copy";
          theme =
            if cfg.lightAndDarkMode.enable
            then "light:Rose Pine Dawn,dark:Rose Pine"
            else "Rose Pine";
          window-decoration = if pkgs.stdenv.isDarwin then "auto" else "none"; # needs to be auto on macos for rounded corners
          window-padding-color = "extend";
        }
        (mkIf (cfg.font.family != null)
          { font-family = cfg.font.family; })
        (mkIf (cfg.shaders != [ ]) {
          custom-shader = map (s: "${shaders."${s}"}") cfg.shaders;
        })
      ];
    };
  };
}
