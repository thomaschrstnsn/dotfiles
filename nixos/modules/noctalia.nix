{ config, lib, pkgs, noctalia, ... }:

with lib;

let
  cfg = config.tc.noctalia;
in
{
  options.tc.noctalia = with types; {
    enable = mkEnableOption "the noctalia desktop shell";

    configFile = mkOption {
      type = path;
      description = ''
        noctalia config.toml for the user, export the current one with
        `noctalia config export > config.toml`
      '';
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

    home-manager.users.${config.tc.user.name} = {
      imports = [ noctalia.homeModules.default ];
      programs.noctalia = {
        enable = true;
        settings = builtins.readFile cfg.configFile;
      };
    };
  };
}
