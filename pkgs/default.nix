{ pkgs, nixpkgs, system, inputs, ... }:
with pkgs;
{
  myPkgs = {
    sketchybar = import ./sketchybar { inherit pkgs nixpkgs; };
    appleFonts = import ./apple-fonts { inherit pkgs; };
    pyenv-nix-install = inputs.pyenv-nix-install.packages.${system}.default;
  };
}
