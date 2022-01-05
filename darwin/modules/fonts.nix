{ pkgs, lib, ... }:

{
  fonts = {
    enableFontDir = true;
    # JetBrainsMono Nerd Font
    # MesloLGS Nerd Font
    fonts = [ pkgs.myNerdfonts ];
  };
}
