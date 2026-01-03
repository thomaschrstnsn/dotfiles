{ pkgs, config, lib, ... }:

{
  imports = [
    ./aerospace.nix
    ./fonts.nix
    ./homebrew.nix
    ./ice.nix
    ./jankyborders.nix
    ./mermaid-cli.nix
    ./osx.nix
    ./sketchybar.nix
    ./skhd.nix
    ./yabai.nix
  ];
}
