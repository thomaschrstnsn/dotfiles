{ sshKeys, ... }:

let
  username = "thomas";
in
{
  home = {
    user = {
      username = username;
      homedir = "/home/thomas";
    };
    direnv.enable = true;
    jj = {
      enable = true;
      publicKeyFile = "~/.ssh/github-personal.pub";
    };
    ssh = {
      enable = true;
      hosts = [ "rpi4" "vmnix" "enix" "rsync.net" ];
      publicKeys = {
        "github-personal.pub" = sshKeys.personal.access.publicKey;
      };
    };
    fish.enable = true;
    git = {
      enable = true;
      publicKeyFile = "~/.ssh/github-personal.pub";
    };
    tmux = {
      enable = true;
      remote = true;
      theme = "rose-pine";
    };
    lazyvim.enable = true;
    vim = {
      enable = false;
    };
  };
  extraPackages = pkgs: with pkgs; [
    devenv
    lnav
  ];

  system = "x86_64-linux";

  nixos = {
    config = {
      networking.hostname = "enix";
      user = {
        name = username;
        groups = [ "wheel" "docker" "navidrome" ];
        defaultShell = "fish";
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
