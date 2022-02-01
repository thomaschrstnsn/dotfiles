{ pkgs, system, lib, myPkgs }:

{
  overlays = [
    (super: self: {
      inherit myPkgs;
      myNerdfonts = self.nerdfonts.override { fonts = [ "JetBrainsMono" "Meslo" ]; };
      sketchybar = pkgs.myPkgs.sketchybar;
      yabai = pkgs.myPkgs.yabai;
    })
  ];
}
