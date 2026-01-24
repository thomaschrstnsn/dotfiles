{ pkgs, nixpkgs, system, inputs, ... }:
with pkgs;
{
  myPkgs = {
    aeroTrafficControl = callPackage ./aetc.nix { };
    sketchybar = import ./sketchybar { inherit pkgs nixpkgs; };
    appleFonts = import ./apple-fonts { inherit pkgs; };
    pyenv-nix-install = inputs.pyenv-nix-install.packages.${system}.default;
    zen-browser = inputs.zen-browser.packages."${system}".default;
    github-copilot-cli = callPackage ./github-copilot-cli { };
  };
}
