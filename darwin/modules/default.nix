{ pkgs, config, lib, ... }:

{
  imports = [
    ./aerospace.nix
    ./fonts.nix
    ./homebrew.nix
    ./ice.nix
    ./osx.nix
    ./sketchybar.nix
    ./skhd.nix
    ./yabai.nix
  ];
}
