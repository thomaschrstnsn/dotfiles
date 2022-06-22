{ pkgs, config, lib, ... }:

{
  imports = [
    # ./nord-theme.nix

    ./fonts.nix
    ./homebrew.nix
    ./osx.nix
    ./sketchybar.nix
    ./skhd.nix
    ./yabai.nix
  ];
}
