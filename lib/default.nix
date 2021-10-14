{ pkgs, home-manager, system, lib, overlays, ... }:
rec {
  user = import ./user.nix { inherit pkgs home-manager lib system overlays; };
}
