{ pkgs, lib, ... }:

{
  system.defaults.finder = {
    AppleShowAllExtensions = true;
    _FXShowPosixPathInTitle = true;
  };

  system.defaults.dock = {
    orientation = "right";
    autohide = true;
    mru-spaces = false;
  };

  system.defaults.spaces.spans-displays = false;

  system.defaults.screencapture.location = "~/Desktop/screenshots";

  system.defaults.NSGlobalDomain = {
    InitialKeyRepeat = 15;
    KeyRepeat = 2;
  };

  # todo: enable Accessibility > Display > Reduce Motion 
  # todo: osx spaces configuration 
}