{ pkgs, config, lib, ... }:

{
  imports = [
    ./osx.nix
    ./sketchybar.nix
    ./skhd.nix
    ./spacebar.nix
    ./yabai.nix
  ];
}
