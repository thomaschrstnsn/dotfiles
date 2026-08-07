{ pkgs, lib }:

let version = "0.0.1";
in
pkgs.rustPlatform.buildRustPackage {
  pname = "hyprfocus";
  inherit version;

  src = pkgs.fetchFromGitHub {
    owner = "thomaschrstnsn";
    repo = "hyprfocus";
    rev = "65511a6e09f23a72c235065e0d1cb56041e14f5c";
    hash = "sha256-BM31v24H8kC8rjG+Ri4C9AS0y5McrNUiRJ7n8fk2x4g";
  };

  cargoHash = "sha256-TFSiDr7xT5Hc5ch1T14pdjoWSRoOk5yWP6EfkfA7PMs";

  meta = with pkgs.lib; {
    description = "hyprland focus helper";
    license = licenses.mit;
    platforms = lib.platforms.linux;
  };
}

