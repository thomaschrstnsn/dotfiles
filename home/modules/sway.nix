{ pkgs, config, lib, ... }:
with lib;

let cfg = config.tc.vim;
in
{
  options.tc.sway = {
    enable = mkEnableOption "sway";
  };

  config = mkIf cfg.enable {
    options.wayland.windowManager.sway = {
      enable = true;
    };
  };
}
