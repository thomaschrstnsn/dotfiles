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
  # (cd pkgs/dotnet && ./update-dotnet-versions.sh 2.2 3.1 6.0 7.0)
  dotnet_5_0 = import ./versions/6.0.nix buildAttrs;
  dotnet_6_0 = import ./versions/6.0.nix buildAttrs;
  dotnet_7_0 = import ./versions/7.0.nix buildAttrs;
  dotnet_8_0 = import ./versions/7.0.nix buildAttrs;
in
dotnet_5_0 // dotnet_6_0 // dotnet_7_0 // dotnet_8_0

