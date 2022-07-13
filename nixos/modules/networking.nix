{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.tc.networking;
in
{
  options.tc.networking = with types; {
    hostname = mkOption {
      type = str;
      description = "hostname";
    };
  };

  config = {
    networking.hostName = cfg.hostname;
  };
}



