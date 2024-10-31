{ config, pkgs, lib, ... }:

let
  userCfg = config.tc.user;
in
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
      "@admin" "${userCfg.name}"
    ];
  };

  users.users."${userCfg.name}".home = userCfg.homedir;

  services.nix-daemon.enable = true;
  nix.configureBuildUsers = true;

  system.stateVersion = 4;
}
