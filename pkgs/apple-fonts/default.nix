{ pkgs, ... }:
with pkgs;

let
  makeAppleFont = name: src:
    pkgs.stdenv.mkDerivation {
      inherit name src;

      version = "0.3.0";

      unpackPhase = ''
        runHook preUnpack

        # Apple ships the fonts in a DMG holding an installer package. Newer
        # DMGs are APFS based (undmg only understands HFS), so let 7z dig
        # through the image: it either extracts the package or the payload.
        7z x -y "$src"

        pkg=$(find . -name '*.pkg' -print -quit)
        if [ -n "$pkg" ]; then
          7z x -y "$pkg"
        fi

        # The payload is a cpio archive with the fonts.
        bsdtar xf Payload~

        runHook postUnpack
      '';

      buildInputs = [
        pkgs.p7zip
        pkgs.libarchive
      ];
      setSourceRoot = "sourceRoot=`pwd`";

      installPhase = ''
        mkdir -p $out/share/fonts
        mkdir -p $out/share/fonts/opentype
        mkdir -p $out/share/fonts/truetype
        find -name \*.otf -exec mv {} $out/share/fonts/opentype/ \;
        find -name \*.ttf -exec mv {} $out/share/fonts/truetype/ \;
      '';
    };

  sources = import ./sources.nix;
in
{
  sf-pro = makeAppleFont "sf-pro" (pkgs.fetchurl sources.sf-pro);
  sf-compact = makeAppleFont "sf-compact" (pkgs.fetchurl sources.sf-compact);
  sf-mono = makeAppleFont "sf-mono" (pkgs.fetchurl sources.sf-mono);
  sf-arabic = makeAppleFont "sf-arabic" (pkgs.fetchurl sources.sf-arabic);
  ny = makeAppleFont "ny" (pkgs.fetchurl sources.ny);
}
