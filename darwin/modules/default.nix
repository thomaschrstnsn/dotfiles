{ pkgs, config, lib, ... }:

{
  imports = [
    ./fonts.nix
    ./homebrew.nix
    ./ice.nix
    ./osx.nix
    ./sketchybar.nix
    ./skhd.nix
    ./yabai.nix
  ];
}
