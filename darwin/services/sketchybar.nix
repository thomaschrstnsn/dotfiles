{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.sketchybar-custom;

  configHome = "${pkgs.myPkgs.sketchybar.config}/sketchybarrc";
in
{
  options = with types;
    {
      services.sketchybar-custom.enable = mkEnableOption "sketchybar";

      services.sketchybar-custom.package = mkOption {
        type = path;
        description = "The sketchybar package to use.";
      };
    };

  config = mkIf
    (cfg.enable)
    {
      environment.systemPackages = with pkgs; [
        cfg.package
        lua5_4
        nowplaying-cli
      ];

      homebrew.casks = [
        "sf-symbols"
        "font-sf-mono"
        "font-sf-pro"
      ];

      homebrew.brews = [
        "switchaudio-osx"
      ];

      fonts.packages = [
        pkgs.myPkgs.sketchybar.sketchybar-app-font
      ];

      launchd.user.agents.sketchybar = {
        serviceConfig.ProgramArguments = [ "${cfg.package}/bin/sketchybar" "-c" "${configHome}" ];

        serviceConfig.KeepAlive = true;
        serviceConfig.RunAtLoad = true;
        serviceConfig.EnvironmentVariables = {
          PATH = "${cfg.package}/bin:${config.environment.systemPath}:${pkgs.lua5_4}/bin";
        };
      };
    };
}



