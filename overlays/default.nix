{ pkgs, system, lib, myPkgs }:

{
  overlays = [
    (final: prev: {
      inherit myPkgs;
    })
  ];
}
