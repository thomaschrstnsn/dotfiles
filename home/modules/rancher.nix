{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.rancher;
in
{
  options.tc.rancher = {
    enable = mkEnableOption "rancher";
  };

  config = mkIf cfg.enable {
    programs.zsh.initContent = lib.mkOrder 550 ''
      export PATH=$PATH:~/.rd/bin
    '';
  };
}
