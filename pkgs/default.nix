{ pkgs, nixpkgs, ... }:
with pkgs;
{
  myPkgs = {
    sketchybar = import ./sketchybar { inherit pkgs nixpkgs; };
  };
}
