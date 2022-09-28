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
      editor = "vim";
    };
    tmux.enable = true;
  };
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
