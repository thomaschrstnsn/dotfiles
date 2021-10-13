{ pkgs, home-manager, system, lib, ... }:
rec {
  user = import ./user.nix { inherit pkgs home-manager lib system; };
}
