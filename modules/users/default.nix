{ pkgs, config, lib, ... }:

{
  imports = [
    ./aws.nix
    ./dotnet.nix
    ./git.nix
    ./zsh.nix
    
    ./haskell
  ];
}
