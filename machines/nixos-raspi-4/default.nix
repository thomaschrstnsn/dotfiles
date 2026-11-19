{ sshKeys, inputs, ... }:

let
  username = "pi";
in
{
  home = [{
    user = {
      inherit username;
      homedir = "/home/${username}";
    };
    direnv.enable = true;
    jj = {
      enable = true;
      publicKeyFile = "~/.ssh/github-personal.pub";
    };
    git.enable = true;
    zsh = {
      enable = true;
    };
    scripts = { enable = true; onlyCore = true; };
    ssh = {
      enable = true;
      hosts = [ "rpi4" "enix" "rsync.net" ];
      publicKeys = {
        "github-personal.pub" = sshKeys.personal.access.publicKey;
      };
    };
    fish.enable = true;
    tmux = {
      enable = true;
      remote = true;
      vtmux = {
        enable = true;
        paneInactiveBlend = "fg=bg/25,bg=bg/25";
        kittyKeys = true;
        inbandResize = true;
      };
    };
    lazyvim.enable = true;
    yazi.enable = false;
  }];
  system = "aarch64-linux";

  extraPackages = pkgs: with pkgs; [
  ];

  nixos = {
    determinateNix = false;
    config = {
      user = {
        name = username;
        groups = [ "wheel" "docker" ];
        defaultShell = "fish";
      };
      networking.hostname = "nixos-raspi-4";
    };
    base = {
      imports = [
        ./configuration.nix
        ./cloudflare.nix

        inputs.nixos-hardware.nixosModules.raspberry-pi-4
      ];

    };
  };
}
