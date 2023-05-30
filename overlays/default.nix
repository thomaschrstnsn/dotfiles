{ pkgs, system, lib, myPkgs }:

{
  overlays = [
    (self: super: {
      inherit myPkgs;

      gum = myPkgs.gum;

      myNerdfonts = self.nerdfonts.override { fonts = [ "JetBrainsMono" "Meslo" ]; };

      sketchybar =
        super.sketchybar.overrideAttrs (
          o: rec {
            version = "2.15.1";
            src = super.fetchFromGitHub {
              owner = "FelixKratz";
              repo = "SketchyBar";
              rev = "v${version}";
              sha256 = "sha256-0jCVDaFc7ZvA8apeHRoQvPhAlaGlBHzqUkS9or88PcM";
            };
          }
        );
    })
  ];
}
