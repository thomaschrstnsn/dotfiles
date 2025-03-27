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
      "@admin"
      "${userCfg.name}"
    ];
  };

  users.users."${userCfg.name}".home = userCfg.homedir;

  nix.enable = true;

  system.stateVersion = 4;
}
