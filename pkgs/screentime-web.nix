{ pkgs, lib }:

let version = "0.0.1";
in
pkgs.rustPlatform.buildRustPackage {
  pname = "screentime-web";
  inherit version;

  src = pkgs.fetchFromGitHub {
    owner = "thomaschrstnsn";
    repo = "screentime-web";
    rev = "f1e4db1045481cb032a3d3652ffb25d4fd8eec10";
    hash = "sha256-E12VaP/aH8CGQxBwNQIIqG+3rqjk1Wg+O/7ZgSHG7Ys";
  };

  cargoHash = "sha256-URE4Jt6E0kzOworZj2SnPFlfW4Wo17jje0psWkMbKoc";

  meta = with pkgs.lib; {
    description = "screentime-web";
    license = licenses.mit;
    platforms = lib.platforms.linux;
  };
}

