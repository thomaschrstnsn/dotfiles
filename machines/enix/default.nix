{ ... }:

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
    };
    ssh = {
      enable = true;
      hosts = [ "rpi4" "vmnix" "enix" "rsync.net" ];
    };
    fish.enable = true;
    git.enable = true;
    tmux = {
      enable = true;
      remote = true;
    };
    vim = {
      enable = true;
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
