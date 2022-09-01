{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [ ];

  programs = {
    zsh = {
      enable = true;
      promptInit = "";
    };
  };

  nix.settings = {
    trusted-users = [
      "@admin"
    ];
  };

  services.nix-daemon.enable = true;
  nix.configureBuildUsers = true;

  system.stateVersion = 4;
}
