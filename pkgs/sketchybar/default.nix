{ pkgs, lib, stdenv, fetchFromGitHub }:

# https://github.com/NixOS/nixpkgs/blob/2bee70d513298c4a439680df3792594c0b0baa63/pkgs/os-specific/darwin/sketchybar/default.nix
# in master, perhaps soon in nixpkgs-unstable
# 2.4.3 not starting on aarch64

let
  inherit (stdenv.hostPlatform) system;
  target = {
    "aarch64-darwin" = "arm";
    "x86_64-darwin" = "x86";
  }.${system} or (throw "Unsupported system: ${system}");
in

stdenv.mkDerivation rec {
  pname = "sketchybar";
  version = "2.3.0";

  src = fetchFromGitHub {
    owner = "FelixKratz";
    repo = "SketchyBar";
    rev = "v${version}";
    sha256 = "sha256-54AJCK0JoT5zBjWRujxVrKrm+HGW81GdlEMZGd7ZC8Y=";
  };

  buildInputs = with pkgs.darwin.apple_sdk.frameworks; [
    Carbon
    Cocoa
    SkyLight
  ];

  postPatch = ''
    sed -i -e '/^#include <malloc\/_malloc.h>/d' src/*.[ch] src/*/*.[ch]
  '';

  makeFlags = [
    target
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp ./bin/sketchybar_${target} $out/bin/sketchybar
  '';

  meta = with lib; {
    description = "A highly customizable macOS status bar replacement";
    homepage = "https://github.com/FelixKratz/SketchyBar";
    platforms = platforms.darwin;
    maintainers = [ maintainers.azuwis ];
    license = licenses.gpl3;
  };
}
