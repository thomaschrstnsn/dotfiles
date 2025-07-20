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
    fish.enable = true;
    ghostty = {
      enable = true;
      fontsize = 13;
      windowBackgroundOpacity = 0.7;
      lightAndDarkMode.enable = false;
      package = inputs.ghostty.packages.${system}.default; # for the shader support in (unreleased) 1.2
    };
    git = {
      enable = true;
      gpgVia1Password = true;
    };
    jj = {
      enable = true;
      gpgVia1Password = true;
    };
    tmux = {
      enable = true;
      remote = false;
      theme = "rose-pine";
      cliptool = "wl-copy";
    };
    hyprland = {
      enable = true;
      terminal = "ghostty";
    };
    wezterm = {
      # package = inputs.wezterm.packages.${system}.default;
      enable = true;
      fontsize = 11.5;
      window_decorations.resize = false;
      window_padding.override = true;
      windowBackgroundOpacity = 0.7;
      textBackgroundOpacity = 0.6;
    };
    vim = {
      enable = true;
    };
  };
  extraPackages = pkgs: with pkgs; [
    _1password-gui
    devenv
    logseq
    lnav
    morgen
    spotify
    todoist-electron
    qt5.qtwayland
    webcord-vencord
    myPkgs.zen-browser
    wine64
  ];

  system = system;

  nixos = {
    config = {
      networking.hostname = "atlas";
      user = {
        name = username;
        groups = [ "wheel" "docker" "gamemode" ];
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
