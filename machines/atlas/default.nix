{ systems, inputs, ... }:

let
  username = "thomas";
  system = systems.x64-linux;
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
    tmux = {
      enable = true;
      remote = false;
      theme = "rose-pine";
    };
    hyprland.enable = true;
    wezterm = {
      package = inputs.wezterm.packages.${system}.default;
      enable = true;
      fontsize = 11.5;
      window_decorations.resize = false;
      window_padding.override = true;
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
  ];

  system = system;

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
