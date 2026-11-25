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
      homedir = "/home/${username}";
    };
    desktop.enable = true;
    direnv.enable = true;
    ssh = {
      enable = true;
      hosts = [ "rpi4" "atlas" "cyrus" "enix" "rsync.net" ];
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
      font.size = 11;
      font.family = "Sarasa Term SC";
      lightAndDarkMode.enable = false;
      # keep it light for the Intel HD 5000
      shaders = [ ];
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
      theme = "rose-pine";
      cliptool = "wl-copy";
      vtmux = {
        enable = true;
        paneInactiveBlend = "fg=bg/25,bg=bg/25";
        kittyKeys = true;
        notifications = true;
        inbandResize = true;
        graphics = true;
      };
    };
    hyprland = {
      enable = true;
      terminal = "ghostty";
      keyboard = "kanata";
      shell = "noctalia";
      kbVariant = "mac,mac";
      effects = "minimal";
      layout = "dwindle";
      idle.suspend = 600;
      laptop = {
        brightnessKeys = true;
        touchpad = true;
      };
      autostartTerminalOn = "t";
      autostart = [
        { command = "zen"; workspace = "b"; }
        { command = "1password"; workspace = "p"; }
      ];
    };
    lazyvim = {
      enable = true;
      gh.enable = true;
      lang = {
        python.enable = true;
        markdown.enable = true;
        markdown.zk.enable = true;
      };
    };
  }];

  extraPackages = pkgs: with pkgs; [
    inputs.claude-code.packages.${stdenv.hostPlatform.system}.claude-code
    qt5.qtwayland
    myPkgs.zen-browser
  ];

  inherit system;

  nixos = {
    config = {
      networking.hostname = "aero-nix";
      user = {
        name = username;
        groups = [ "wheel" "networkmanager" "video" ];
        defaultShell = "fish";
      };
      hyprland = {
        enable = true;
        autologin = true;
        bluetooth.enable = true;
      };
      laptop.enable = true;
      noctalia = {
        enable = true;
        # starts blank, export with: noctalia config export > machines/aero-nix/noctalia/config.toml
        configFile = ./noctalia/config.toml;
      };
    };
    base = {
      imports = [
        ./configuration.nix

        inputs.nixos-hardware.nixosModules.apple-macbook-air-6
      ];
    };
  };
}
