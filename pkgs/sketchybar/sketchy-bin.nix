{ stdenvNoCC, fetchurl, lib }:

# facepalm: but cannot build the x86 on one machine in nix, works outside

#  > clang src/manifest.m -std=c99 -Wall -DNDEBUG -Ofast -fvisibility=hidden -target x86_64-apple-macos10.13 -F/System/Library/PrivateFrameworks -framework Carbon -framework Cocoa -framework SkyLight  -o bin/sketchybar_x86
#  > In file included from src/manifest.m:16:
#  > src/misc/env_vars.h:5:10: fatal error: 'malloc/_malloc.h' file not found
#  > #include <malloc/_malloc.h>
#  >          ^~~~~~~~~~~~~~~~~~
#  > 1 error generated.

stdenvNoCC.mkDerivation {
  pname = "sketchybar";
  version = "2.3.0";

  src = fetchurl {
    url = "file:///Users/thomas.christensen@schibsted.com/src/SketchyBar/sketchy2.3.0.tar.gz";
    sha256 = "sha256-aFN5LjIx9Yq47A7WoaA8/m/5wqqca62AgKLDZQyQUM0=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    mv sketchybar_x86 $out/bin/sketchybar
  '';
}
