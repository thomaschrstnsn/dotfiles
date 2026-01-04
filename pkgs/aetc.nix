{ pkgs }:

let version = "0.4.2";
in
pkgs.rustPlatform.buildRustPackage {
  pname = "aero-traffic-control";
  inherit version;

  src = pkgs.fetchFromGitHub {
    owner = "thomaschrstnsn";
    repo = "aero-traffic-control";
    rev = "12f1a0136d7b3bfa393b250705c91f53e0a5d084";
    hash = "sha256-5XJApyHL25MXr4WeJ2QKa9xVt8smSxleS2Py4wF6GOc";
  };

  cargoHash = "sha256-wkbMEF9clFow3sn+fz3j3EsVPEaoaX55zChvN//ERNA";

  meta = with pkgs.lib; {
    description = "A CLI tool for intelligent window management using AeroSpace";
    license = licenses.mit;
    platforms = platforms.darwin;
  };
}

