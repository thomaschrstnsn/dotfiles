{ pkgs, nixpkgs, system, inputs, ... }:
with pkgs;
{
  myPkgs = {
    aeroTrafficControl = callPackage ./aetc.nix { };
    appleFonts = import ./apple-fonts { inherit pkgs; };
    hyprfocus = inputs.hyprfocus.packages.${system}.default;
    pyenv-nix-install = inputs.pyenv-nix-install.packages.${system}.default;
    tmuxPaneBorderType = callPackage ./tmux-pane-border-type.nix { };
    zen-browser = inputs.zen-browser.packages."${system}".default;
  };
}
