{ pkgs, system, lib, myPkgs, hyprpanel }:

{
  overlays = [
    hyprpanel.overlay
    (self: super: {
      inherit myPkgs;

    })
  ];
}
