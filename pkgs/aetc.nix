{ pkgs }:

let version = "0.3.0";
in
pkgs.rustPlatform.buildRustPackage {
  pname = "aero-traffic-control";
  inherit version;

  src = pkgs.fetchFromGitHub {
    owner = "thomaschrstnsn";
    repo = "aero-traffic-control";
    rev = "v${version}";
    hash = "sha256-/x8O+dLmOs/tyD7wpD6xWnDhWak2Es4UM/hMG03Xkxs";
  };

  cargoHash = "sha256-v4tC7U/fLJx1YkJtANSsmeeWOFkAKp6IQD6tenlt1Vc";

  meta = with pkgs.lib; {
    description = "A CLI tool for intelligent window management using AeroSpace";
    license = licenses.mit;
    platforms = platforms.darwin;
  };
}

