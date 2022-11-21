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
    git.enable = true;
    zsh = {
      enable = true;
      editor = "nvim";
    };
    tmux.enable = true;
    vim.enable = true;
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
