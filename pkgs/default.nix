{ pkgs, nixpkgs, system, inputs, ... }:
with pkgs;
{
  myPkgs = {
    aeroTrafficControl = inputs.aero-traffic-control.packages.${system}.default;
    appleFonts = import ./apple-fonts { inherit pkgs; };
    hyprfocus = inputs.hyprfocus.packages.${system}.default;
    pyenv-nix-install = inputs.pyenv-nix-install.packages.${system}.default;
    sarasaTermSC = callPackage ./sarasa.nix { variant = "TermSC"; };
    tmuxPaneBorderType = callPackage ./tmux-pane-border-type.nix { };
    vtmux = callPackage ./vtmux.nix { };
  };
}
