{ pkgs, config, lib, ... }:
with lib;

let cfg = config.tc.sway;
in
{
  options.tc.sway = {
    enable = mkEnableOption "sway";
  };

  config = mkIf cfg.enable {
    # options.wayland.windowManager.sway = {
    #   enable = true;
    # };
  };
}
