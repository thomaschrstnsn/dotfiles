{ pkgs, config, lib, ... }:

{
  imports = [
    ./bootstrap.nix
    ./fonts.nix
    ./networking.nix
    ./user.nix
  ];
}
