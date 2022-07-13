{ config, lib, pkgs, ... }:

with lib;

# Inspired by: https://mdleom.com/blog/2021/06/15/cloudflare-argo-nixos/

let
  cfg = config.tc.services.cloudflared;
in
{
  options.tc.services.cloudflared = {
    enable = mkEnableOption "Cloudflare Argo Tunnel";

    configFile = mkOption {
      type = types.path;
      description = "Path to cloudflared config";
    };

    secretsFile = mkOption {
      type = types.path;
      description = "Path to cloudflared secrets";
    };

    secretsPathDeployment = mkOption {
      type = types.str;
      description = "Which file (under /etc) to store secrets in";
      default = "cloudflare-secrets.json";
    };

    dataDir = mkOption {
      default = "/var/lib/cloudflared";
      type = types.path;
      description = ''
        The data directory, for storing credentials.
      '';
    };

    package = mkOption {
      default = pkgs.cloudflared;
      defaultText = "pkgs.cloudflared";
      type = types.package;
      description = "cloudflared package to use.";
    };
  };

  config = mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      cloudflared
    ];

    users = {
      users.cloudflare = {
        home = cfg.dataDir;
        createHome = true;
        isSystemUser = true;
        group = "cloudflare";
      };

      groups = { cloudflare = { }; };

    };

    environment.etc = {
      "cloudflared.yml" = {
        source = cfg.configFile;
        mode = "0600";
        user = "cloudflare";
      };
      ${cfg.secretsPathDeployment} = {
        source = cfg.secretsFile;
        mode = "0600";
        user = "cloudflare";
      };
    };

    systemd.services.cloudflared = {
      description = "cloudflared Tunnel";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ]; # systemd-networkd-wait-online.service
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.cloudflared}/bin/cloudflared --config /etc/cloudflared.yml --no-autoupdate tunnel run";
        Type = "simple";
        User = "cloudflare";
        Group = "cloudflare";
        Restart = "on-failure";
        RestartSec = "5s";
        NoNewPrivileges = true;
        LimitNPROC = 512;
        LimitNOFILE = 1048576;
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectHome = true;
        ProtectSystem = "full";
        ReadWriteDirectories = cfg.dataDir;
      };
      restartTriggers = [
        (builtins.hashFile "sha256" cfg.configFile)
        (builtins.hashFile "sha256" "/etc/${cfg.secretsPathDeployment}")
      ];
    };

  };
}
