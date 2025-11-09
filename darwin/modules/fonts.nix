{ pkgs, lib, ... }:

{
  fonts = {
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      maple-mono.NF-unhinted
    ];
  };
}
