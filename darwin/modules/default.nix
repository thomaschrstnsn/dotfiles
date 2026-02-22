{ pkgs, config, lib, ... }:

{
  imports = [
    ./aerospace.nix
    ./fonts.nix
    ./homebrew.nix
    ./jankyborders.nix
    ./mermaid-cli.nix
    ./osx.nix
    ./skhd.nix
    ./sleepwatcher.nix
  ];
}
