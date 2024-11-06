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
      hosts = [ "rpi4" "vmnix" "enix" "rsync.net" "logseq-personal-deploy" ];
      use1PasswordAgent = true;
    };
    git = {
      enable = true;
      gpgVia1Password = true;
    };
    jj = {
      enable = true;
      gpgVia1Password = true;
    };
    zsh = {
      enable = true;
    };
    tmux = {
      enable = true;
      remote = false;
      theme = "rose-pine";
      cliptool = "wl-copy";
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
    _1password-gui
    brave
    devenv
    logseq
    morgen
    spotify
    todoist-electron
    qt5.qtwayland
    webcord-vencord
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
