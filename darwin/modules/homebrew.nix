{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.tc.homebrew;
in
{
  options.tc.homebrew = with types; {
    enable = mkEnableOption "homebrew";
    extraCasks = mkOption {
      description = "additional casks to install";
      type = listOf str;
      default = [ ];
    };
    extraBrews = mkOption
      {
        description = "additional brews to setup";
        type = listOf str;
        default = [ ];
      };
    extraTaps = mkOption
      {
        description = "additional taps to setup";
        type = listOf str;
        default = [ ];
      };
  };

  config = mkIf cfg.enable {
    environment.interactiveShellInit = ''
      eval "$(${config.homebrew.brewPrefix}/brew shellenv)"
    '';

    homebrew.enable = true;
    homebrew.onActivation.autoUpdate = true;
    homebrew.onActivation.cleanup = "zap";
    homebrew.global.brewfile = true;
    homebrew.global.lockfiles = true;

    homebrew.masApps = { };

    homebrew.taps = [
    ] ++ cfg.extraTaps;

    homebrew.brews = cfg.extraBrews;

    homebrew.casks = [
      "1password"
      "1password-cli"
      "numi"
      "raycast"
      "spotify"
      "visual-studio-code"
    ] ++ cfg.extraCasks;
  };
}
