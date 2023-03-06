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
    environment.shellInit = ''
      eval "$(${config.homebrew.brewPrefix}/brew shellenv)"
    '';

    homebrew.enable = true;
    homebrew.onActivation.autoUpdate = true;
    homebrew.onActivation.cleanup = "zap";
    homebrew.global.brewfile = true;
    homebrew.global.lockfiles = true;

    homebrew.masApps = {
      # Xcode = 497799835;
      # Todoist = 572688855;
    };


    homebrew.taps = [
      "homebrew/cask"
      "homebrew/cask-versions"
    ] ++ cfg.extraTaps;

    homebrew.brews = cfg.extraBrews;

    homebrew.casks = [
      # "1password-beta"
      "1password-cli"
      "iterm2"
      "karabiner-elements"
      "numi"
      "maccy"
      "raycast"
      "rocket"
      "spotify"
      "visual-studio-code"
      "vlc"
    ] ++ cfg.extraCasks;
  };
}
