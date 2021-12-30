{ pkgs, config, lib, ... }:

{
  imports = [
    ./osx.nix
    ./skhd.nix
    ./spacebar.nix
    ./yabai.nix
  ];
}
