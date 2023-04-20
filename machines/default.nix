{ lib, inputs, ... }:

let
  systems = {
    arm-linux = "aarch64-linux";
    x64-linux = "x86_64-linux";
    m1-darwin = "aarch64-darwin";
    x64-darwin = "x86_64-darwin";
  };

  skhd-scripts = ./darwin/modules/skhd;
in
{
  machines = {
    aero-nix = import ./aero-nix { inherit systems; };
    aeris = import ./aeris { inherit systems; };
    A125228-DK = import ./schibsted { inherit systems skhd-scripts; };
    Atlas = import ./wsl { inherit systems; };
    PC04137 = import ./wsl/dcnix.nix { inherit systems; };
    nixos-raspi-4 = import ./nixos-raspi-4 { inherit systems inputs; };
    vmnix = import ./vmnix { inherit systems; };

    # Minimal configuration to bootstrap darwin systems
    darwin-bootstrap-x64 = {
      system = systems.x64-darwin;
    };
    darwin-bootstrap-aarch64 = {
      system = systems.m1-darwin;
    };
  };
}
