{ inputs, ... }:

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
    git.enable = true;
    zsh = {
      enable = true;
    };
    scripts = { enable = true; onlyCore = true; };
    ssh = {
      enable = true;
      hosts = [ "rpi4" "enix" "rsync.net" ];
    };
    tmux = {
      enable = true;
      remote = true;
    };
    yazi.enable = false;
  }];
  system = "aarch64-linux";

  extraPackages = pkgs: with pkgs; [
  ];

  nixos = {
    config = {
      user = {
        name = username;
        groups = [ "wheel" "docker" ];
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
