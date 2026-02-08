# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      dns = [ "192.168.1.1" ];
    };
  };

  services.plex = {
    enable = true;
    openFirewall = true;
  };

  powerManagement.powertop.enable = true;

  networking.firewall.allowedTCPPorts = [
    3000 # poolmonitor for local testing
    3210 # grafana poolmonitor
    5432 # postgres
    2283 # immich
    6767 # screentime-web
  ];

  environment.systemPackages = with pkgs; [
    docker-compose
    rclone
  ];

  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?
}

