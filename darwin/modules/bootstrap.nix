{ config, pkgs, lib, ... }:

let
  userCfg = config.tc.user;
  # shellCfg = config.tc.shell;
in
{
  # environment.shells = if shellCfg.shell == "fish" then [pkgs.fish] else [];
  environment.shells = [pkgs.fish];

  nix.settings = {
    trusted-users = [
      "@admin"
      "${userCfg.name}"
    ];
  };

  programs.fish.enable = true;

  users.users."${userCfg.name}" = {
    home = userCfg.homedir;

    # will only set the shell if we are creating a new user - so not really useful
    # https://nix-darwin.github.io/nix-darwin/manual/index.html#opt-users.users._name_.shell
    # shell = if shellCfg.shell == "fish" then pkgs.fish else null;
  };

  nix.enable = true;

  system.stateVersion = 4;
}
