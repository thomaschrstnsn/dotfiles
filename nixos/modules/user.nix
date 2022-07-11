{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.tc.user;
in
{
  options.tc.user = with types; {
    enable = mkEnableOption "user";
  };

  config = mkIf (cfg.enable) {
    users = {
      defaultUserShell = pkgs.zsh;
      mutableUsers = false;
      users.thomas = {
        isNormalUser = true;
        hashedPassword = "$6$LCmCC873.y/MhqLa$xrTZFdCYmo.FfCk1fkYCVNvVR1Xq1SrFAoD2a94pYlL7uk0apnrbJJbJIuo6WKofuA3egt7DOEasM44vyPJyZ.";
        extraGroups = [ "wheel" ];
        openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICTvFy5gC46MnA0Eu+DoYQbldwxoJJVd9KVpAFwkS+ZH" ];
      };
    };

  };
}
