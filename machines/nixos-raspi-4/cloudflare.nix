{ config, pkgs, lib, ... }:

{
  config = {
    age.secrets."nixos-raspi-4.cloudflare.json.age".file = ../../secrets/nixos-raspi-4.cloudflare.json.age;

    tc.services.cloudflared = {
      enable = true;
      configFile = ./tunnel/cloudflare.yml;
      secretsFile = config.age.secrets."nixos-raspi-4.cloudflare.json.age".path;
      secretsPathDeployment = "cloudflare-secrets.json";
    };
  };
}
