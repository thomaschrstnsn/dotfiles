{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.skhd;
  mkAppShortcut = (shortcut: app: "${shortcut} : open -a \"${app}\"");
  scripts = ./skhd;
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
    extraAppShortcuts = mkOption {
      description = "Extra shortcuts to open apps";
      type = types.attrsOf types.str;
      default = { };
      example = {
        "hyper - z" = "zoom.us";
      };
    };
  };

  config = mkIf (cfg.enable) {
    environment.systemPackages = with pkgs; [
      jq
    ];

    services.skhd = {
      enable = true;
      # https://github.com/koekeishiya/skhd/issues/1
      skhdConfig =
        ''
          hyper - q : ${scripts}/moveWindowToDisplayAndFollowFocus.sh left
          hyper - w : ${scripts}/moveWindowToDisplayAndFollowFocus.sh right
          hyper - a : yabai -m display --focus prev || yabai -m display --focus last
          hyper - s : yabai -m display --focus next || yabai -m display --focus first

          hyper - o : ${scripts}/moveWindowToSpaceOnSameDisplay.sh prev
          hyper - p : ${scripts}/moveWindowToSpaceOnSameDisplay.sh next
          hyper - tab : ${scripts}/moveWindowToFirstEmptySpaceOnSameDisplay.sh

          hyper - return : ${scripts}/toggleLayoutOnCurrentSpace.sh

          hyper - d : yabai -m space --toggle show-desktop
          hyper - e : yabai -m space --toggle mission-control

          hyper - 1 : ${scripts}/focusFirstWindowInSpace.sh 1
          hyper - 2 : /${scripts}/focusFirstWindowInSpace.sh 2
          hyper - 3 : ${scripts}/focusFirstWindowInSpace.sh 3
          hyper - 4 : ${scripts}/focusFirstWindowInSpace.sh 4
          hyper - 5 : ${scripts}/focusFirstWindowInSpace.sh 5
          hyper - 6 : ${scripts}/focusFirstWindowInSpace.sh 6
          hyper - 7 : ${scripts}/focusFirstWindowInSpace.sh 7
          hyper - 8 : ${scripts}/focusFirstWindowInSpace.sh 8

          hyper - j : yabai -m window --focus west
          hyper - l : yabai -m window --focus east
          hyper - i : yabai -m window --focus north
          hyper - k : yabai -m window --focus south

          hyper - m : yabai -m window --toggle native-fullscreen
          hyper - f : yabai -m window --toggle zoom-fullscreen

          hyper - left  : yabai -m window --resize left:-20:0; \
                          yabai -m window --resize right:-20:0;
          hyper - right : yabai -m window --resize right:20:0; \
                          yabai -m window --resize left:20:0;
          hyper - down  : yabai -m window --resize top:0:20; \
                          yabai -m window --resize bottom:0:20
          hyper - up    : yabai -m window --resize bottom:0:-20; \
                          yabai -m window --resize top:0:-20

          hyper - space : yabai -m space --rotate 270

          # app shortcuts
          hyper - b : open -a "${cfg.browser}"
          hyper - t : open -a "iTerm"
          hyper - x : open -a "Visual Studio Code"
        ''
        + concatStringsSep "\n" (attrValues (mapAttrs mkAppShortcut cfg.extraAppShortcuts))
      ;
    };
  };
}
