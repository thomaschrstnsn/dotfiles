{ pkgs, config, lib, ... }:

{
  imports = [
    ./bootstrap.nix
    ./fonts.nix
    ./kanata.nix
    ./networking.nix
    ./user.nix
  ];
}
