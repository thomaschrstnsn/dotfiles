{ systems, inputs, ... }:

let
  username = "pi";
in
{
  home = {
    user = {
      username = username;
      homedir = "/home/${username}";
    };
    direnv.enable = true;
    git.enable = true;
    zsh = {
      enable = true;
    };
    ssh = {
      enable = true;
      hosts = [ "rpi4" "vmnix" "enix" "rsync.net" ];
    };
    tmux = {
      enable = true;
      remote = true;
    };
    vim = {
      enable = true;
      treesitter.grammarPackageSet = "slim";
      copilot.enable = false;
    };
  };
  system = systems.arm-linux;

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
