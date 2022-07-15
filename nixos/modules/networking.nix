{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.tc.networking;
in
{
  options.tc.networking = with types; {
    enable = mkOption
      {
        description = "networking";
        type = bool;
        default = true;
      };
    hostname = mkOption {
      type = str;
      description = "hostname";
    };
  };

  config = mkIf cfg.enable {
    networking.hostName = cfg.hostname;
  };
}
