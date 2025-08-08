{ config, pkgs, lib, ... }:

with lib;

let
  userCfg = config.tc.user;
  # shellCfg = config.tc.shell;
  nixCfg = config.tc.nix;
in
{
  options.tc.nix.daemon = with types; {
    enable = mkEnableOption "enable nix daemon via nix-darwin (disabled on determinate nix, which provides its own)" // { default = true; };
  };

  config = {
    # environment.shells = if shellCfg.shell == "fish" then [pkgs.fish] else [];
    environment.shells = [ pkgs.fish ];

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

    nix.enable = nixCfg.daemon.enable;
    nix.optimise.automatic = nixCfg.daemon.enable;

    system.stateVersion = 4;
  };
}
