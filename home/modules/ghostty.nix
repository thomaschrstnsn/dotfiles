{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.ghostty;
in
{
  options.tc.ghostty = with types; {
    enable = mkEnableOption "ghostty (terminal emulator)";

    fontsize = mkOption {
      type = types.number;
      description = "fontsize in terminal";
      default = 15.2;
    };

    windowBackgroundOpacity = mkOption {
      type = types.number;
      description = "background opacity";
      default = 1.0;
      example = 0.7;
    };

    shaders = mkEnableOption "custom sharders" // { default = true; };
  };

  config = mkIf cfg.enable {
    programs.ghostty = {
      enable = true;
      package = null; # on macOS we get it from homebrew
      # installBatSyntax = true; # only when package is not null
      settings = mkMerge [{
        background-blur = true;
        background-opacity = cfg.windowBackgroundOpacity;
        cursor-style-blink = true;
        font-size = cfg.fontsize;
        initial-window = true;
        macos-window-shadow = false;
        macos-titlebar-style = "hidden";
        # window-decoration = "none"; # needs to be auto on macos for rounded corners
        minimum-contrast = 1.1;
        theme = "light:rose-pine-dawn,dark:rose-pine";
      }
        (mkIf cfg.shaders {
          custom-shader = "${./ghostty/shaders/cursor_blaze.glsl}";
        })];
    };
  };
}
