{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.tc.jankyborders;
in
{
  options.tc.jankyborders = with types; {
    enable = mkEnableOption "jankyborders (highlight active window with borders)";
  };
  config = mkIf cfg.enable {
    services.jankyborders = {
      enable = true;
      active_color = "0xffe1e3e4";
      inactive_color = "0xff494d64";
      blur_radius = 5.0;
      width = 4.0;
    };
  };
}
