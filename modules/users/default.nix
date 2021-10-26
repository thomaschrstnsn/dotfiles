{ pkgs, config, lib, ... }:

{
  imports = [
    ./aws.nix
    ./dotnet.nix
    ./git.nix
    ./nodejs.nix
    ./tmux.nix
    ./zsh.nix
    
    ./haskell
  ];
}
