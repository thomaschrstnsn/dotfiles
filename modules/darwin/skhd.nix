{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.skhd;
in
{
  options.tc.skhd = {
    enable = mkOption {
      description = "Enable simple hotkey deamon";
      type = types.bool;
      default = false;
    };
    browser = mkOption {
      description = "Which app to use as browser shortcut";
      type = types.str;
      default = "Safari";
    };
  };

  config = mkIf (cfg.enable) {
    environment.systemPackages = with pkgs; [
      jq
      terminal-notifier
    ];
    environment.etc."skhd-moveWindowToDisplayAndFollowFocus.sh".source = ./skhd/moveWindowToDisplayAndFollowFocus.sh;
    environment.etc."skhd-moveWindowToSpaceOnSameDisplay.sh".source = ./skhd/moveWindowToSpaceOnSameDisplay.sh;
    environment.etc."skhd-toggleLayoutOnCurrentSpace.sh".source = ./skhd/toggleLayoutOnCurrentSpace.sh;
    environment.etc."skhd-focusFirstWindowInSpace.sh".source = ./skhd/focusFirstWindowInSpace.sh;
    environment.etc."skhd-moveWindowToFirstEmptySpaceOnSameDisplay.sh".source = ./skhd/moveWindowToFirstEmptySpaceOnSameDisplay.sh;

    services.skhd = {
      enable = true;
      # https://github.com/koekeishiya/skhd/issues/1
      skhdConfig = (builtins.readFile ./skhd/skhdrc) + ''
        # app shortcuts
        hyper - b : open -a "${cfg.browser}"
        hyper - t : open -a "iTerm"
        hyper - x : open -a "Visual Studio Code"
        hyper - z : open -a "zoom.us"
        hyper - c : open -a "Slack"
        hyper - r : open -a "Rider"
      '';
    };
  };
}
