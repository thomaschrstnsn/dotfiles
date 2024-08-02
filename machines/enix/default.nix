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
    ssh = {
      enable = true;
      hosts = [ "rpi4" "vmnix" "enix" "rsync.net" ];
    };
    git.enable = true;
    zsh = {
      enable = true;
      editor = "vim";
    };
    tmux.enable = true;
    tmux.remote = true;
    vim = {
      enable = true;
    };
  };
  extraPackages = pkgs: with pkgs; [
  ];

  system = systems.x64-linux;

  nixos = {
    config = {
      networking.hostname = "enix";
      user = {
        name = username;
        groups = [ "wheel" "docker" "navidrome" ];
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
