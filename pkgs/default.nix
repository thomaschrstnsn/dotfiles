{ pkgs, nixpkgs, ... }:
with pkgs;
{
  myPkgs = {
    dotnet = callPackage ./dotnet { inherit nixpkgs; };

    gum = callPackage ./gum { };
  };
}
