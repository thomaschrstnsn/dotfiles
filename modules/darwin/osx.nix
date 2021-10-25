{ pkgs, lib, ... }:

{
  system.defaults.dock = {
    orientation = "right";
    autohide = true;
  };

  system.defaults.NSGlobalDomain = {
    InitialKeyRepeat = 15;
    KeyRepeat = 2;
  };

  # todo: enable Accessibility > Display > Reduce Motion 
}