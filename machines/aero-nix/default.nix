{ systems, ... }:
let
  username = "thomas";
  configurationRoot = ./nixos/machines/aero-nix;
in
{
  home = {
    user = {
      username = username;
      homedir = "/home/${username}";
    };
    dotnet = {
      enable = true;
      sdks = [ "6.0" ];
    };
    git.enable = true;
    ssh = {
      enable = true;
      hosts = [ "rpi4" "vmnix" ];
    };
    zsh = {
      enable = true;
    };
  };

  extraPackages = pkgs: with pkgs; [
    brave
    shellcheck
    rnix-lsp
    nixpkgs-fmt
    _1password-gui
    vscode
    wl-clipboard
  ];

  nixos = {
    config = {
      user = {
        name = username;
        groups = [ "wheel" ];
      };
      networking.hostname = "aero-nix";
    };
    base = {
      imports = [
        ./configuration.nix
      ];
    };
  };

  system = systems.x64-linux;
}
