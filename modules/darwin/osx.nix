{ pkgs, lib, ... }:

{
  system.defaults.dock = {
    orientation = "right";
    autohide = true;
  };

  system.defaults.NSGlobalDomain = {
    InitialKeyRepeat = 15;
    KeyRepeat = 2;
    _HIHideMenuBar = true;
  };

  # todo: enable Accessibility > Display > Reduce Motion 
}