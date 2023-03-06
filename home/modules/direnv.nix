{ pkgs, config, lib, ... }:
with lib;

let cfg = config.tc.direnv;
in
{
  options.tc.direnv = {
    enable = mkEnableOption "direnv";
  };

  config = mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
