{ pkgs, nixpkgs, icu70, icu, ... }:

with pkgs;
let
  buildDotnet = attrs: callPackage (import "${nixpkgs}/pkgs/development/compilers/dotnet/build-dotnet.nix" attrs) { };
  buildAttrs = {
    buildAspNetCore = attrs: buildDotnet (attrs // { type = "aspnetcore"; });
    buildNetRuntime = attrs: buildDotnet (attrs // { type = "runtime"; });
    buildNetSdk = attrs: buildDotnet (attrs // { type = "sdk"; });
  };
  # Updated via:
  # ./pkgs/dotnet/update-dotnet-versions.sh 2.2 3.1 6.0
  dotnet_2_2 = import ./versions/2.2.nix (buildAttrs // { icu = icu70; });
  dotnet_3_1 = import ./versions/3.1.nix (buildAttrs // { icu = icu70; });
  dotnet_6_0 = import ./versions/6.0.nix (buildAttrs // { inherit icu; });
in
dotnet_2_2 // dotnet_3_1 // dotnet_6_0

