{ pkgs, config, lib, ... }:

{
  imports = [
    ./bootstrap.nix
    ./user.nix
  ];
}
