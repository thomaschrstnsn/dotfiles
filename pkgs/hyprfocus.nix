{ pkgs, lib }:

let version = "0.0.1";
in
pkgs.rustPlatform.buildRustPackage {
  pname = "hyprfocus";
  inherit version;

  src = pkgs.fetchFromGitHub {
    owner = "thomaschrstnsn";
    repo = "hyprfocus";
    rev = "53b63fbab6bfeebd3ed57da2b5ff72f8c2a510d6";
    hash = "sha256-5NppSuktTl/D8ag0uyBzAnkn1WHokEIS4gwKen1eNN8=";
  };

  cargoHash = "sha256-vk0kxc5jWjq80DYbTpz+kPu6c7ObBkgXDQu6KM2orT8";

  meta = with pkgs.lib; {
    description = "hyprland focus helper";
    license = licenses.mit;
    platforms = lib.platforms.linux;
  };
}

