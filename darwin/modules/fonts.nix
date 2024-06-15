{ pkgs, lib, ... }:

{
  fonts = {
    # JetBrainsMono Nerd Font
    # MesloLGS Nerd Font
    packages = [ pkgs.myNerdfonts ];
  };
}
