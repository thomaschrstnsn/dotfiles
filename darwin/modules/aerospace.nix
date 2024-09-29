{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.tc.aerospace;
in
{
  options.tc.aerospace = with types; {
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

    services.skhd.skhdConfig = '''';
  };
}
