{ pkgs, nixpkgs, ... }:
with pkgs;
{
  myPkgs = {
    dotnet = callPackage ./dotnet { inherit nixpkgs; };
    sketchybar = import ./sketchybar {inherit pkgs nixpkgs; };
  };
}
