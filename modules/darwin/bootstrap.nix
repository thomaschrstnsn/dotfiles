{ config, pkgs, lib, ... }:

{
  imports = [
    ../../base/shared.nix
  ];

  nix = {
    trustedUsers = [
      "@admin"
    ];
  };

  services.nix-daemon.enable = true;
  services.nix-daemon.enableSocketListener = true;
  users.nix.configureBuildUsers = true;

  system.stateVersion = 4;
}