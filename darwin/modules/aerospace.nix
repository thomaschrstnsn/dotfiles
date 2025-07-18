{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.tc.aerospace;

  toSkhdConfig = attrs: concatLines (mapAttrsToList (key: cmd: "${key}: aerospace ${cmd}") attrs);
in
{
  options.tc.aerospace = with types;
    {
      enable = mkEnableOption "aerospace tiling window manager https://github.com/nikitabobko/AeroSpace";
    };
  config = mkIf cfg.enable {
    services.aerospace = {
      enable = true;
      settings = {
        on-focused-monitor-changed = [ "move-mouse monitor-lazy-center" ];
        on-focus-changed = [ "move-mouse window-lazy-center" ];
        gaps = {
          inner.horizontal = 6;
          inner.vertical = 6;
          outer.left = 6;
          outer.bottom = 6;
          outer.top = 6;
          outer.right = 6;
        };
        mode.main.binding = {
          alt-slash = "layout tiles horizontal vertical";
          alt-shift-slash = "layout accordion horizontal vertical";

          alt-h = "move left";
          alt-j = "move down";
          alt-k = "move up";
          alt-l = "move right";

          alt-shift-h = "join-with left";
          alt-shift-j = "join-with down";
          alt-shift-k = "join-with up";
          alt-shift-l = "join-with right";

          # A,S,D,F missing
          # alt-a = "workspace A";
          alt-b = "workspace B";
          alt-c = "workspace C";
          # alt-d = "workspace D";
          alt-e = "workspace E";
          # alt-f = "workspace F";
          alt-g = "workspace G";
          alt-i = "workspace I";
          alt-m = "workspace M";
          alt-n = "workspace N";
          alt-o = "workspace O";
          alt-p = "workspace P";
          alt-q = "workspace Q";
          alt-r = "workspace R";
          # alt-s = "workspace S";
          alt-t = "workspace T";
          alt-u = "workspace U";
          alt-v = "workspace V";
          alt-w = "workspace W";
          alt-x = "workspace X";
          alt-y = "workspace Y";
          alt-z = "workspace Z";

          # alt-shift-a = "move-node-to-workspace A";
          alt-shift-b = "move-node-to-workspace B";
          alt-shift-c = "move-node-to-workspace C";
          # alt-shift-d = "move-node-to-workspace D";
          alt-shift-e = "move-node-to-workspace E";
          # alt-shift-f = "move-node-to-workspace F";
          alt-shift-g = "move-node-to-workspace G";
          alt-shift-i = "move-node-to-workspace I";
          alt-shift-m = "move-node-to-workspace M";
          alt-shift-n = "move-node-to-workspace N";
          alt-shift-o = "move-node-to-workspace O";
          alt-shift-p = "move-node-to-workspace P";
          alt-shift-q = "move-node-to-workspace Q";
          alt-shift-r = "move-node-to-workspace R";
          # alt-shift-s = "move-node-to-workspace S";
          alt-shift-t = "move-node-to-workspace T";
          alt-shift-u = "move-node-to-workspace U";
          alt-shift-v = "move-node-to-workspace V";
          alt-shift-w = "move-node-to-workspace W";
          alt-shift-x = "move-node-to-workspace X";
          alt-shift-y = "move-node-to-workspace Y";
          alt-shift-z = "move-node-to-workspace Z";

          alt-tab = "workspace-back-and-forth";
          alt-shift-semicolon = "mode service";
        };
        mode.service.binding = {
          esc = [ "reload-config" "mode main" ];
          r = [ "flatten-workspace-tree" "mode main" ]; # reset layout
          f = [ "layout floating tiling" "mode main" ]; # Toggle between floating and tiling layout
          backspace = [ "close-all-windows-but-current" "mode main" ];
        };
      };
    };

    system.defaults.NSGlobalDomain._HIHideMenuBar = true;

    # https://nikitabobko.github.io/AeroSpace/guide#a-note-on-displays-have-separate-spaces
    system.defaults.spaces.spans-displays = true;
    # https://nikitabobko.github.io/AeroSpace/guide#a-note-on-mission-control
    system.defaults.dock.expose-group-apps = true;

    services.skhd.skhdConfig = toSkhdConfig {
      "hyper - q" = "move-workspace-to-monitor --wrap-around prev";
      "hyper - w" = "move-workspace-to-monitor --wrap-around next";
      "hyper - f" = "fullscreen";
      "hyper - h" = "focus left";
      "hyper - j" = "focus down";
      "hyper - k" = "focus up";
      "hyper - l" = "focus right";
      "hyper - left" = "resize smart -50";
      "hyper - right" = "resize smart +50";
      "hyper - escape" = "reload-config";
    };
  };
}
