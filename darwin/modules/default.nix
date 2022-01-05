{ pkgs, config, lib, ... }:

{
  imports = [
    ./fonts.nix
    ./osx.nix
    ./sketchybar.nix
    ./skhd.nix
    ./spacebar.nix
    ./yabai.nix
  ];
}
