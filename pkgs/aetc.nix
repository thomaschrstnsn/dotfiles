{ pkgs }:

let version = "0.4.0";
in
pkgs.rustPlatform.buildRustPackage {
  pname = "aero-traffic-control";
  inherit version;

  src = pkgs.fetchFromGitHub {
    owner = "thomaschrstnsn";
    repo = "aero-traffic-control";
    rev = "v${version}";
    hash = "sha256-P4ni0PxfQx80gK3jilc+qQrDllDJYh9DJ3YvUhmcByE";
  };

  cargoHash = "sha256-H85JRBEZ7Zg6PyEYO4Q0w4SMPaVPTsl065xZW+B5row";

  meta = with pkgs.lib; {
    description = "A CLI tool for intelligent window management using AeroSpace";
    license = licenses.mit;
    platforms = platforms.darwin;
  };
}

