{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.user;
in
{
  options.tc.user = with types; {
    username = mkOption {
      type = str;
    };
    homedir = mkOption {
      type = nullOr str;
    };
  };

  config = {
    home = {
      packages = with pkgs; [ ];
    } // mkIf (cfg.homedir != null) {
      homeDirectory = cfg.homedir;
    };
  };
}
