{ inputs, ... }:

{
  machines = {
    aero-nix = import ./aero-nix { inherit inputs; };
    atlas = import ./atlas { inherit inputs; };
    aeris = import ./aeris { inherit inputs; };
    tilia = import ./lind { inherit inputs; };
    enix = import ./enix/default.nix { inherit inputs; };
    Atlas = import ./wsl/atlas.nix { inherit inputs; };
    nixos-raspi-4 = import ./nixos-raspi-4 { inherit inputs; };
    vmnix = import ./vmnix { inherit inputs; };
  };
}
