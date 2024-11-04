{ systems, ... }:

let
  username = "thomas";
in
{
  home = {
    user = {
      username = username;
      homedir = "/home/thomas";
    };
    git.enable = true;
    zsh = {
      enable = true;
    };
    tmux.enable = true;
    tmux.remote = true;
    vim = {
      enable = true;
      treesitter.grammarPackageSet = "slim";
    };
  };
  extraPackages = pkgs: with pkgs; [
    cachix
    jq
  ];

  system = systems.arm-linux;

  nixos = {
    config = {
      networking.hostname = "vmnix";
      user = {
        name = username;
        groups = [ "wheel" "docker" ];
      };
    };
    base = {
      imports =
        [
          ./hardware.nix
          ./configuration.nix
        ];
    };
  };
}
