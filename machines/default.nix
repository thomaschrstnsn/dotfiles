{ inputs, ... }:

{
  machines = {
    aero-nix = import ./aero-nix { inherit inputs; };
    atlas = import ./atlas { inherit inputs; };
    aeris = import ./aeris { inherit inputs; };
    "MFT-L6407N5H2V" = import ./mft { inherit inputs; };
    enix = import ./enix/default.nix { inherit inputs; };
    Atlas = import ./wsl { inherit inputs; };
    nixos-raspi-4 = import ./nixos-raspi-4 { inherit inputs; };
    vmnix = import ./vmnix { inherit inputs; };
  };
}
