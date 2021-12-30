{ pkgs, config, lib, ... }:

{
  imports = [
    ./stack.nix
    ./ihp.nix
  ];
}
