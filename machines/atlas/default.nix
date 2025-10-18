{ inputs, sshKeys, ... }:

let
  username = "thomas";
  system = "x86_64-linux";
in
{
  home = [{
    user = {
      inherit username;
      homedir = "/home/thomas";
    };
    desktop.enable = true;
    direnv.enable = true;
    ssh = {
      enable = true;
      hosts = [ "rpi4" "enix" "rsync.net" ];
      _1password = {
        enableAgent = true;
        keys = [
          sshKeys.personal.access._1passwordId
          sshKeys.personal.signing._1passwordId
        ];
      };
      publicKeys = {
        "github-personal.pub" = sshKeys.personal.access.publicKey;
      };
    };
    fish.enable = true;
    ghostty = {
      enable = true;
      fontsize = 13;
      windowBackgroundOpacity = 0.7;
      lightAndDarkMode.enable = false;
      package = inputs.ghostty.packages.${system}.default;
      shaders = [ "cursor_blaze_tapered" ];
    };
    git = {
      enable = true;
      gpgVia1Password.enable = true;
      gpgVia1Password.key = sshKeys.personal.signing.publicKey;
      publicKeyFile = "~/.ssh/github-personal.pub";
      alternativeConfigs = {
        "~/logseq.personal/" = { publicKeyFile = "~/.ssh/logseq-personal-deploy_ed25519"; };
      };
    };
    jj = {
      enable = true;
      gpgVia1Password.enable = true;
      gpgVia1Password.key = sshKeys.personal.signing.publicKey;
      publicKeyFile = "~/.ssh/github-personal.pub";
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
      keyboard = "keychron-keychron-q11";
    };
    lazyvim = {
      colorscheme = "kanagawa";
      enable = true;
      lang.python.enable = true;
      lang.markdown.notes.enable = true;
    };
  }];
  extraPackages = pkgs: with pkgs; [
    devenv
    logseq
    lnav
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
