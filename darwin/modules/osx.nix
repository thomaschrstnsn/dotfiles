{ pkgs, lib, ... }:

{
  system.defaults.finder = {
    AppleShowAllExtensions = true;
    _FXShowPosixPathInTitle = false;
  };

  system.defaults.dock = {
    orientation = "right";
    autohide = true;
    mru-spaces = false;
    expose-animation-duration = "0";
    autohide-time-modifier = "0";
  };

  system.defaults.LaunchServices.LSQuarantine = false;

  system.defaults.spaces.spans-displays = false;

  system.defaults.screencapture.location = "~/Desktop/screenshots";

  system.defaults.NSGlobalDomain = {
    InitialKeyRepeat = 15;
    KeyRepeat = 2;

    NSAutomaticCapitalizationEnabled = false;
    NSAutomaticDashSubstitutionEnabled = false;
    NSAutomaticPeriodSubstitutionEnabled = false;
    NSAutomaticQuoteSubstitutionEnabled = false;
    NSAutomaticSpellingCorrectionEnabled = false;

    NSNavPanelExpandedStateForSaveMode = true;
    NSNavPanelExpandedStateForSaveMode2 = true;

    NSWindowResizeTime = "0";
  };

  # todo: enable Accessibility > Display > Reduce Motion 
  # system.defaults.universalaccess.reduceMotion = 1;
}
