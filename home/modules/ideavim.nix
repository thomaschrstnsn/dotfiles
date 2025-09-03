{ pkgs, config, lib, ... }:
with lib;

let cfg = config.tc.ideavim;
in
{
  options.tc.ideavim = {
    enable = mkEnableOption "ideavim";
  };

  config = mkIf cfg.enable {
    home.file = mkIf cfg.enable {
      ".ideavimrc".source = ./vim/ideavimrc;
    };
  };
}
