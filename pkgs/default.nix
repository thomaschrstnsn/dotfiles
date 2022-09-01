{ pkgs, forgit-git, nixpkgs, ... }:
with pkgs;
{
  myPkgs = {
    zsh-forgit = callPackage ./zsh-forgit { inherit forgit-git; };

    dotnet = callPackage ./dotnet { inherit nixpkgs; };

    gum = callPackage ./gum { };
  };
}
