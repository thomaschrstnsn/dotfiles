{ pkgs, nixpkgs, system, inputs, ... }:
with pkgs;
{
  myPkgs = {
    aeroTrafficControl = callPackage ./aetc.nix { };
    appleFonts = import ./apple-fonts { inherit pkgs; };
    github-copilot-cli = callPackage ./github-copilot-cli { };
    hyprfocus = callPackage ./hyprfocus.nix { };
    pyenv-nix-install = inputs.pyenv-nix-install.packages.${system}.default;
    sketchybar = import ./sketchybar { inherit pkgs nixpkgs; };
    timekpr-collector = callPackage ./timekpr-collector.nix { };
    zen-browser = inputs.zen-browser.packages."${system}".default;
  };
}
