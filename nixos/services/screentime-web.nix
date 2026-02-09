{ config, lib, pkgs, ... }:

with lib;

# Inspired by: https://mdleom.com/blog/2021/06/15/cloudflare-argo-nixos/

let
  cfg = config.tc.services.screentime-web;
in
{
  options.tc.services.screentime-web = {
    enable = mkEnableOption "screentime-web service (nats to http)";
  };

  config = mkIf cfg.enable {

    users = {
      users.stweb = {
        isSystemUser = true;
        group = "stweb";
      };

      groups = { stweb = { }; };

    };

    systemd.services.screentime-web = {
      description = "screentime-web service";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ]; # systemd-networkd-wait-online.service
      wantedBy = [ "multi-user.target" ];

      environment = {
        CF_ACCESS_TEAM = "chrstnsn";
        CF_ACCESS_AUD = "dc7601a2fd567cb444c9903776b771765ecb853bdcde878c3f136be1534c7de5";
      };

      serviceConfig = {
        ExecStart = "${pkgs.myPkgs.screentime-web}/bin/screentime-web --nats-url 192.168.1.163:4222 --bind 0.0.0.0:6767";
        Type = "simple";
        User = "stweb";
        Group = "stweb";
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
