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

    services.yabai.config = {
      external_bar = "main:${toString 0}:0";
    };
    homebrew.taps = [ "nikitabobko/tap" ];
    homebrew.casks = [ "aerospace" ];
  };
}
