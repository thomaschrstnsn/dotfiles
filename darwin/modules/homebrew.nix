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
      # Homebrew >=5.x refuses `brew bundle install --cleanup` non-interactively
      # without an explicit force flag; authorize the zap cleanup to run unattended.
      onActivation.extraFlags = [ "--force-cleanup" ];
      global.brewfile = true;

      masApps = { };

      # Any tap added here is non-official; trust it so Homebrew >=6.0 `brew bundle`
      # will load its formulae/casks during non-interactive activation (Tap Trust).
      taps = map (name: { inherit name; trusted = true; }) cfg.extraTaps;

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
