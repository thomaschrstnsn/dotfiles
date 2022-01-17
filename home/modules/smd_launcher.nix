{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.smd_launcher;
in
{
  options.tc.smd_launcher = {
    enable = mkEnableOption "smd-launcher";
  };

  config = mkIf (cfg.enable) {
    home.file."bin/open-iterm.sh".source = ./smd_launcher/open-iterm.sh;
  };
}
