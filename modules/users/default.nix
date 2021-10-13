{ pkgs, config, lib, ... }:

{
  imports = [
    ./git.nix
    ./zsh.nix
    ./aws.nix
    ./haskell
  ];
}
