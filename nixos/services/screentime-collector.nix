{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.tc.services.screentime-collector;
in
{
  options.tc.services.screentime-collector = {
    enable = mkEnableOption "screentime-collector service (dbus to nats)";
  };

  config = mkIf cfg.enable {

    users = {
      users.stcol = {
        isSystemUser = true;
        group = "stcol";
      };

      groups = { stcol = { }; };

    };

    systemd.services.screentime-collector = {
      description = "screentime-collector service";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ]; # systemd-networkd-wait-online.service
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.myPkgs.screentime-collector}/bin/screentime-collector -n nats://enix.local:4222 -u conrad --hostname cyrus";
        Type = "simple";
        User = "stcol";
        Group = "stcol";
        Restart = "on-failure";
        RestartSec = "5s";
        NoNewPrivileges = true;
        LimitNPROC = 512;
        LimitNOFILE = 1048576;
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectHome = true;
        ProtectSystem = "full";
      };
    };
  };
}
