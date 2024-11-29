{ pkgs, system, lib, myPkgs, hyprpanel }:

{
  overlays = [
    hyprpanel.overlay
    (self: super: {
      inherit myPkgs;

      myNerdfonts = self.nerdfonts.override { fonts = [ "JetBrainsMono" "Meslo" "NerdFontsSymbolsOnly" ]; };
    })
  ];
}
