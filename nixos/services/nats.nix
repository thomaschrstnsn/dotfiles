{ config, lib, ... }:

with lib;

# NATS with JetStream for screentime. Streams are not declared here: the
# collector creates them.
let
  cfg = config.tc.services.nats;
in
{
  options.tc.services.nats = {
    enable = mkEnableOption "NATS server with JetStream";
  };

  config = mkIf cfg.enable {
    services.nats = {
      enable = true;
      jetstream = true;
      port = 4222;
      settings = {
        # a vanished client reads as gone after ~1 minute instead of ~4
        ping_interval = "20s";
        # monitoring stays local to the host: only 4222 is opened below
        http_port = 8222;
      };
    };

    networking.firewall.allowedTCPPorts = [ config.services.nats.port ];
  };
}
