{ pkgs, config, lib, ... }:

{
  imports = [
    ./aws.nix
    ./dotnet.nix
    ./git.nix
    ./tmux.nix
    ./zsh.nix
    
    ./haskell
  ];
}
