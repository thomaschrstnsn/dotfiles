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

      yabai = super.yabai.overrideAttrs
        (
          o: rec {
            version = "5.0.6";
            src = super.fetchzip {
              url = "https://github.com/koekeishiya/yabai/releases/download/v${version}/yabai-v${version}.tar.gz";
              sha256 = "sha256-wpm9VnR4yPk6Ybo/V2DMLgRcSzDl3dWGSKDCjYfz+xQ";
            };
          }
        );
    }
    )
  ];
}
