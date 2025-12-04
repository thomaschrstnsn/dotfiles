{ inputs, sshKeys, ... }:

let
  username = "thomas";
  system = "x86_64-linux";

  zkPersonal = {
    "~/zk.personal/" = {
      publicKeyFile = "~/.ssh/zk.personal-deploy-key_ed25519";
    };
  };

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
      font.size = 13;
      font.family = "Maple Mono NF";
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
      alternativeConfigs = zkPersonal;
    };
    jj = {
      enable = true;
      gpgVia1Password.enable = true;
      gpgVia1Password.key = sshKeys.personal.signing.publicKey;
      publicKeyFile = "~/.ssh/github-personal.pub";
      alternativeConfigs = zkPersonal;
    };
    tmux = {
      enable = true;
      remote = false;
      theme = "powerkit";
      cliptool = "wl-copy";
    };
    hyprland = {
      enable = true;
      terminal = "ghostty";
      keyboard = "keychron-keychron-q11";
    };
    rust = {
      enable = true;
      linker = "mold";
    };
    lazyvim = {
      colorscheme = "everforest";
      enable = true;
      lang = {
        python.enable = true;
        markdown.enable = true;
        markdown.zk.enable = true;
      };
    };
    webapps.enable = true;
  }];
  extraPackages = pkgs: with pkgs; [
    devenv
    logseq
    lnav
    spotify
    todoist-electron
    qt5.qtwayland
    # webcord-vencord
    vesktop
    myPkgs.zen-browser
    wine64

    inputs.nix-citizen.packages.${system}.star-citizen
    # inputs.nix-citizen.packages.${system}.star-citizen-umu
  ];

  inherit system;

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
