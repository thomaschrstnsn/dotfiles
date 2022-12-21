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
            version = "2.8.6";
            src = super.fetchFromGitHub {
              owner = "FelixKratz";
              repo = "SketchyBar";
              rev = "v${version}";
              sha256 = "sha256-57Jd358pSyt++q4yrte2IVhB06KWvF/noEBy+toFncI=";
            };
          }
        );

      # https://github.com/azuwis/nix-config/tree/c38647695bd6180a2037dfa1675d5a9322250a3c/pkgs/yabai
      yabai = super.callPackage ./yabai { };
    })
  ];
}
