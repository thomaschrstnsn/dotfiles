{ pkgs, config, lib, ... }:

{
  imports = [
    ./hmuser.nix
    ./skhd.nix
  ];
}
