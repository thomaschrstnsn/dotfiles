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
  };

  config = mkIf cfg.enable {
    programs.ghostty = {
      enable = true;
      package = null; # on macOS we get it from homebrew
      # installBatSyntax = true; # only when package is not null
      # todo: cursor trail/smears https://github.com/BryceBeagle/nixos-config/issues/176
      settings = {
        background-blur = true;
        background-opacity = cfg.windowBackgroundOpacity;
        font-size = cfg.fontsize;
        initial-window = true;
        macos-window-shadow = false;
        mouse-hide-while-typing = true;
        minimum-contrast = 1.1;
        theme = "light:rose-pine-dawn,dark:rose-pine";
        window-decoration = "none";
      };
    };
  };
}
