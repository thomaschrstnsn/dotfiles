{ pkgs, config, lib, ... }:

{
  imports = [
    ./bootstrap.nix
    ./fonts.nix
    ./kanata.nix
    ./noctalia.nix
    ./networking.nix
    ./user.nix
  ];
}
