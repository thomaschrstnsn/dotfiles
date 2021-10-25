{ pkgs, darwin, lib, overlays, ... }:
with builtins;
{
  mkDarwinSystem = {extraModules, system}: darwin.lib.darwinSystem {
    inherit system;
    modules = [
      ../base/shared.nix
      ../modules/darwin/osx.nix
      ] ++ extraModules;
  };
}
