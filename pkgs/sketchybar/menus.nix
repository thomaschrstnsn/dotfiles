{ stdenv, pkgs }:

stdenv.mkDerivation {
  name = "menus";
  src = ../../darwin/modules/sketchybar/helpers/menus;

  buildInputs = with pkgs.darwin.apple_sdk.frameworks; [ Carbon SkyLight ];

  installPhase = ''
    mkdir -p $out/bin
    cp ./bin/menus $out/bin/
  '';
}
