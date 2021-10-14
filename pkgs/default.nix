{ pkgs, forgit-git, ... }:
with pkgs;
{
  myPkgs = {
     zsh-forgit = callPackage ./zsh-forgit { inherit forgit-git; };
  };
}
