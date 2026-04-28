{ config, lib, ... }:

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
    homebrew = {
      enable = true;
      onActivation.autoUpdate = true;
      onActivation.cleanup = "zap";
      global.brewfile = true;

      masApps = { };

      taps = [
      ] ++ cfg.extraTaps;

      brews = cfg.extraBrews;

      casks = [
        "1password"
        "numi"
        "raycast"
        "spotify"
        "visual-studio-code"
      ] ++ cfg.extraCasks;
    };
  };
}
