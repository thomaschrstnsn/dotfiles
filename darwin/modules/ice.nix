{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.tc.ice;
in
{
  options.tc.ice = with types; {
    enable = mkEnableOption "ice (bar) from jordanbaird";
  };
  config = mkIf cfg.enable {
    system.defaults.NSGlobalDomain._HIHideMenuBar = true;

    services.yabai.config = {
      external_bar = "main:${toString 0}:0";
    };
    homebrew.casks = [ "jordanbaird-ice" "istat-menus" ];
  };
}
