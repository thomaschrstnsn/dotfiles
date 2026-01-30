{ config, lib, ... }:

with lib;

let
  cfg = config.tc.aerospace;

  appIdsToDesktops = {
    # this rule works against mini-Arc popping up where ever you are working
    # "company.thebrowser.Browser" = "B";

    "com.microsoft.Outlook" = "C";
    "com.microsoft.teams2" = "C";

    "com.spotify.client" = "M";

    "com.webcatalog.juli.icloud-calendar" = "P";
    "com.apple.iCal" = "P";

    "com.todoist.mac.Todoist" = "P";

    "com.mitchellh.ghostty" = "T";

    "com.electron.logseq" = "U";
  };

  workspaceBinds = ws: {
    "alt-${ws}" = "workspace ${toUpper ws}";
    "alt-shift-${ws}" = "move-node-to-workspace --focus-follows-window ${toUpper ws}";
  };

  workspaces = stringToCharacters "bcegimnopqrtuvwxyz"; # minus hjkl and asdf

  workspaceBindingsComplete = foldl' (acc: v: acc // v) { } (map workspaceBinds workspaces);

  focusBind = key: direction: {
    "alt-${key}" = "focus --boundaries-action wrap-around-all-monitors --boundaries all-monitors-outer-frame ${direction}";
  };

  focusBindingsComplete = foldl' (acc: v: acc // v) { } (mapAttrsToList (key: direction: focusBind key direction) { h = "left"; j = "down"; k = "up"; l = "right"; });

  onWindowDetected = mapAttrsToList
    (appId: desktop: {
      "if".app-id = appId;
      run = [ "move-node-to-workspace ${desktop}" ];
    })
    appIdsToDesktops;

  toSkhdConfig = attrs: concatLines (mapAttrsToList (key: cmd: "${key}: aerospace ${cmd}") attrs);
in
{
  options.tc.aerospace = with types; {
    enable = mkEnableOption "aerospace tiling window manager https://github.com/nikitabobko/AeroSpace";
    hideMenuBar = mkOption {
      type = types.bool;
      default = false;
      description = "Hide the menu bar (equivalent to setting _HIHideMenuBar to true)";
    };
  };
  config = mkIf cfg.enable {
    services.aerospace = {
      enable = true;
      settings = {
        on-focused-monitor-changed = [ "move-mouse monitor-lazy-center" ];
        on-focus-changed = [ "move-mouse window-lazy-center" ];
        accordion-padding = 0;
        gaps = {
          inner = {
            horizontal = 2;
            vertical = 2;
          };
          outer = {
            left = 2;
            bottom = 4;
            top = 2;
            right = 2;
          };
        };
        mode.main.binding = {
          alt-slash = "layout tiles horizontal vertical";
          alt-shift-slash = "layout accordion horizontal vertical";

          alt-shift-h = "move left";
          alt-shift-j = "move down";
          alt-shift-k = "move up";
          alt-shift-l = "move right";

          # ctrl-alt-h = "join-with left";
          # ctrl-alt-j = "join-with down";
          # ctrl-alt-k = "join-with up";
          # ctrl-alt-l = "join-with right";

          alt-tab = "workspace-back-and-forth";
          alt-shift-semicolon = "mode service";
        } // workspaceBindingsComplete // focusBindingsComplete;
        mode.service.binding = {
          esc = [ "reload-config" "mode main" ];
          r = [ "flatten-workspace-tree" "mode main" ]; # reset layout
          f = [ "layout floating tiling" "mode main" ]; # Toggle between floating and tiling layout
          backspace = [ "close-all-windows-but-current" "mode main" ];
        };

        on-window-detected = onWindowDetected;
      };
    };

    system = {
      defaults = {
        NSGlobalDomain._HIHideMenuBar = cfg.hideMenuBar;

        # https://nikitabobko.github.io/AeroSpace/guide#a-note-on-displays-have-separate-spaces
        spaces.spans-displays = true;
        # https://nikitabobko.github.io/AeroSpace/guide#a-note-on-mission-control
        dock.expose-group-apps = true;
      };
    };

    services.skhd.skhdConfig = toSkhdConfig {
      "hyper - q" = "move-workspace-to-monitor --wrap-around prev";
      "hyper - w" = "move-workspace-to-monitor --wrap-around next";
      "hyper - f" = "fullscreen";
      "hyper - left" = "resize smart -50";
      "hyper - right" = "resize smart +50";
      "hyper - escape" = "reload-config";
    };
  };
}
