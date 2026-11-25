{ pkgs, config, lib, ... }:

{
  imports = [
    ./bootstrap.nix
    ./fonts.nix
    ./hyprland.nix
    ./kanata.nix
    ./laptop.nix
    ./noctalia.nix
    ./networking.nix
    ./user.nix
  ];
}
