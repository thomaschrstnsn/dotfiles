{ pkgs, nixpkgs, system, inputs, ... }:
with pkgs;
{
  myPkgs = {
    aeroTrafficControl = callPackage ./aetc.nix { };
    blink-cmp-fixed = callPackage ./blink-cmp-fixed.nix { };
    sketchybar = import ./sketchybar { inherit pkgs nixpkgs; };
    appleFonts = import ./apple-fonts { inherit pkgs; };
    pyenv-nix-install = inputs.pyenv-nix-install.packages.${system}.default;
    starship-jj = inputs.starship-jj.packages.${system}.default;
    zen-browser = inputs.zen-browser.packages."${system}".default;
    github-copilot-cli = callPackage ./github-copilot-cli { };
  };
}
