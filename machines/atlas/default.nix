{ systems, inputs, ... }:

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
    tmux.remote = false;
    hyprland.enable = true;
    wezterm = {
      enable = true;
      fontsize = 11.5;
    };
    vim = {
      enable = true;
    };
  };
  extraPackages = pkgs: with pkgs; [
    devenv
    _1password-gui
    brave
    dmenu
    qt5.qtwayland

    wezterm
  ];

  system = systems.x64-linux;

  nixos = {
    config = {
      networking.hostname = "atlas";
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
