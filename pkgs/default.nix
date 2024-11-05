{ pkgs, nixpkgs, ... }:
with pkgs;
{
  myPkgs = {
    sketchybar = import ./sketchybar { inherit pkgs nixpkgs; };
    appleFonts = import ./apple-fonts { inherit pkgs; };
  };
}
