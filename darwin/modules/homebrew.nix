{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.tc.homebrew;
in
{
  options.tc.homebrew = with types; {
    enable = mkEnableOption "homebrew";
  };

  config = mkIf (cfg.enable) {
    environment.shellInit = ''
      eval "$(${config.homebrew.brewPrefix}/brew shellenv)"
    '';

    homebrew.enable = true;
    homebrew.autoUpdate = true;
    homebrew.cleanup = "zap";
    homebrew.global.brewfile = true;
    homebrew.global.noLock = true;

    homebrew.masApps = {
      # Xcode = 497799835;
      Todoist = 572688855;
    };

    homebrew.casks = [
      "1password-beta"
      "1password-cli"
      "google-drive"
      "inkdrop"
      "karabiner-elements"
      "maccy"
      "rocket"
      "visual-studio-code"
      "vlc"
    ];
  };
}
