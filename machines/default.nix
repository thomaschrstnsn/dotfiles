{ inputs, ... }:

let
  sshKeys = {
    personal.access = {
      _1passwordId = "abzfs445wgvufgybncdcjgptla";
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICTvFy5gC46MnA0Eu+DoYQbldwxoJJVd9KVpAFwkS+ZH";
    };
    personal.signing = {
      _1passwordId = "6ddacbrzis56q7qmq5bkinjsum";
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIErz7lXsjPyJcjzRKMWyZodRGzjkbCxWu/Lqk+NpjupZ";
    };
    mft.access = {
      _1passwordId = "lksx2w2y2iewhnbbczk7lg4d2a";
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKOu8nwGPqqqz9fRAAGk7b9ZP5Y7kNd3u/efxUTGFeto";
    };
    mft.signing = {
      _1passwordId = "uczvt65unrn2iqsshuvyuhysky";
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINfb3NXjwOznbBFJ4QQ0WWmDrZncdHof4Y9VVZYrxX7J";
    };
  };
in
{
  machines = {
    aero-nix = import ./aero-nix { inherit inputs sshKeys; };
    atlas = import ./atlas { inherit inputs sshKeys; };
    aeris = import ./aeris { inherit inputs sshKeys; };
    "MFT-L6407N5H2V" = import ./mft { inherit inputs sshKeys; };
    enix = import ./enix/default.nix { inherit inputs sshKeys; };
    Atlas = import ./wsl { inherit inputs sshKeys; };
    nixos-raspi-4 = import ./nixos-raspi-4 { inherit inputs sshKeys; };
    vmnix = import ./vmnix { inherit inputs sshKeys; };
  };
}
