{ pkgs, config, lib, ... }:

{
  imports = [
    ./fonts.nix
    ./homebrew.nix
    ./osx.nix
    ./sketchybar.nix
    ./skhd.nix
    ./spacebar.nix
    ./yabai.nix
  ];
}
