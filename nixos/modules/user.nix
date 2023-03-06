{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.tc.user;
in
{
  options.tc.user = with types; {
    enable = mkOption {
      description = "enable a default known user";
      default = true;
      type = bool;
    };
    name = mkOption {
      type = str;
      description = "username";
    };
    groups = mkOption {
      type = listOf str;
      default = [ "wheel" ];
      description = "groups for the user";
    };
  };

  config = mkIf cfg.enable {
    users = {
      defaultUserShell = pkgs.zsh;
      mutableUsers = false;
      users."${cfg.name}" = {
        isNormalUser = true;
        hashedPassword = "$6$LCmCC873.y/MhqLa$xrTZFdCYmo.FfCk1fkYCVNvVR1Xq1SrFAoD2a94pYlL7uk0apnrbJJbJIuo6WKofuA3egt7DOEasM44vyPJyZ.";
        extraGroups = cfg.groups;
        openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICTvFy5gC46MnA0Eu+DoYQbldwxoJJVd9KVpAFwkS+ZH" ];
      };
    };

  };
}
