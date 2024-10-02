{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.tc.aerospace;

  toSkhdConfig = attrs: concatLines (mapAttrsToList (key: cmd: "${key}: /opt/homebrew/bin/aerospace ${cmd}") attrs);
in
{
  options.tc.aerospace = with types;
    {
      enable = mkEnableOption "aerospace tiling window manager https://github.com/nikitabobko/AeroSpace";
    };
  config = mkIf cfg.enable {
    system.defaults.NSGlobalDomain._HIHideMenuBar = true;

    homebrew.taps = [ "nikitabobko/tap" ];
    homebrew.casks = [ "aerospace" ];

    # https://nikitabobko.github.io/AeroSpace/guide#a-note-on-displays-have-separate-spaces
    system.defaults.spaces.spans-displays = true;
    # https://nikitabobko.github.io/AeroSpace/guide#a-note-on-mission-control
    system.defaults.dock.expose-group-by-app = true;

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
