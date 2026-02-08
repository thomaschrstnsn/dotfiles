{ config, lib, pkgs, ... }:

with lib;

# Inspired by: https://mdleom.com/blog/2021/06/15/cloudflare-argo-nixos/

let
  cfg = config.tc.services.timekpr-collector;
in
{
  options.tc.services.timekpr-collector = {
    enable = mkEnableOption "timekpr-collector service (dbus to nats)";
  };

  config = mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      cloudflared
    ];

    users = {
      users.tkcol = {
        isSystemUser = true;
        group = "tkcol";
      };

      groups = { tkcol = { }; };

    };

    systemd.services.timekpr-collector = {
      description = "timekpr-collector service";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ]; # systemd-networkd-wait-online.service
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.myPkgs.timekpr-collector}/bin/timekpr-dbus-demo";
        Type = "simple";
        User = "tkcol";
        Group = "tkcol";
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
      # restartTriggers = [
      #   cfg.configFile
      # ];
    };
  };
}
