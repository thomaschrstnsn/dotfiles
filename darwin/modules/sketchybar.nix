{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.tc.sketchybar;
in
{
  options.tc.sketchybar = with types; {
    enable = mkEnableOption "sketchybar";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ jq choose ];

    launchd.user.agents.sketchybar.serviceConfig = {
      StandardErrorPath = "/tmp/sketchybar.log";
      StandardOutPath = "/tmp/sketchybar.log";
    };

    services.sketchybar-custom = {
      enable = true;
      package = pkgs.sketchybar;
    };
    services.yabai.config = {
      external_bar = "main:${toString 40}:0";
    };

    system.defaults.NSGlobalDomain._HIHideMenuBar = true;
  };
}
