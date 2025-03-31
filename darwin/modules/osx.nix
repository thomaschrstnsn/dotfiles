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
    expose-animation-duration = 0.0;
    autohide-time-modifier = 0.0;
  };

  system.defaults.LaunchServices.LSQuarantine = false;

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

    NSWindowResizeTime = 0.0;
  };

  security.pam.services.sudo_local.touchIdAuth = true;

  # https://write.rog.gr/writing/using-touchid-with-tmux/
  environment = {
    etc."pam.d/sudo_local".text = ''
      # Managed by Nix Darwin
      auth       optional       ${pkgs.pam-reattach}/lib/pam/pam_reattach.so ignore_ssh
      auth       sufficient     pam_tid.so
    '';
  };

  # todo: enable Accessibility > Display > Reduce Motion 
  # system.defaults.universalaccess.reduceMotion = 1;
}
