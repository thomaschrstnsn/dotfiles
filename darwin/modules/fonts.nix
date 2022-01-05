{ pkgs, lib, ... }:

{
  fonts = {
    enableFontDir = true;
    fonts = [ pkgs.myNerdfonts ];
  };
}
