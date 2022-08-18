{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.rancher;
in
{
  options.tc.rancher = {
    enable = mkEnableOption "rancher";
  };

  config = mkIf (cfg.enable) {
    programs.zsh.initExtraBeforeCompInit = ''
      export PATH=$PATH:~/.rd/bin
    '';
  };
}
