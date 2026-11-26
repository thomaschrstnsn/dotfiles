{ pkgs, config, lib, ... }:

{
  imports = [
    ./aerospace.nix
    ./fonts.nix
    ./homebrew.nix
    ./jankyborders.nix
    ./komorebi.nix
    ./osx.nix
    ./sketchybar.nix
    ./skhd.nix
    ./sleepwatcher.nix
  ];
}
