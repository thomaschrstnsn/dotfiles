{ pkgs, home-manager, system, lib, overlays, darwin, ... }:
{
  user = import ./user.nix { inherit pkgs home-manager lib system overlays; };
  darwin = import ./darwin.nix { inherit pkgs darwin home-manager lib system overlays; };
}
