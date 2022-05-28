{ pkgs, lib, ... }:

{
  fonts = {
    fontDir.enable = true;
    # JetBrainsMono Nerd Font
    # MesloLGS Nerd Font
    fonts = [ pkgs.myNerdfonts ];
  };
}
