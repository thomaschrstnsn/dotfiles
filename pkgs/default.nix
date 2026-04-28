{ pkgs, nixpkgs, system, inputs, ... }:
with pkgs;
{
  myPkgs = {
    aeroTrafficControl = callPackage ./aetc.nix { };
    appleFonts = import ./apple-fonts { inherit pkgs; };
    hyprfocus = callPackage ./hyprfocus.nix { };
    pyenv-nix-install = inputs.pyenv-nix-install.packages.${system}.default;
    screentime-web = callPackage ./screentime-web.nix { };
    screentime-collector = callPackage ./screentime-collector.nix { };
    zen-browser = inputs.zen-browser.packages."${system}".default;
  };
}
