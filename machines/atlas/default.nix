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
      hosts = [ "rpi4" "cyrus" "enix" "rsync.net" ];
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
      font.family = "Sarasa Term SC";
      windowBackgroundOpacity = 0.7;
      lightAndDarkMode.enable = false;
      # package = inputs.ghostty.packages.${system}.default;
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
      theme = "rose-pine";
      cliptool = "wl-copy";
      sidebar = "multiplexer-sidebar";
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
      mainMonitor = "HDMI-A-1";
      monitors = [
        # "HDMI-A-1, 5120x1440@240, 0x0, 1, vrr, 1, bitdepth, 10"
        {
          output = "HDMI-A-1";
          mode = "5120x1440@240";
          position = "0x0";
          scale = "1";
          bitdepth = 10;
        }
      ];
      vrr = 2;
      autostartTerminalOn = "t";
      autostart = [
        { command = "zen"; workspace = "b"; }
        { command = "todoist-electron"; workspace = "p"; }
        { command = "1password"; workspace = "p"; }
        { command = "spotify"; workspace = "m"; }
      ];
      extraWindowRules = [
        # Float Steam windows, except primary
        { match = { class = "steam"; }; float = true; }
        { match = { class = "steam"; title = "Steam"; }; tile = true; }

        { match = { class = "^(path of building.exe)"; }; tile = true; }
        { match = { class = "^(path of building-poe2.exe)"; }; tile = true; }
      ];
      devices = [
        {
          name = "thomas’-pegefelt-(gamle)";
          sensitivity = 0.4;
          natural_scroll = true;
        }
      ];
    };
    rust = {
      enable = true;
      linker = "mold";
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
    webapps.enable = true;
  }];
  extraPackages = pkgs: with pkgs; [
    devenv
    lnav
    mermaid-cli
    inputs.claude-code.packages.${stdenv.hostPlatform.system}.claude-code
    spotify
    todoist-electron
    qt5.qtwayland
    # webcord-vencord
    vesktop
    myPkgs.zen-browser
    wine64

    kitty

    # inputs.nix-citizen.packages.${system}.star-citizen
    # inputs.nix-citizen.packages.${system}.star-citizen-umu
  ];

  inherit system;

  nixos = {
    config = {
      networking.hostname = "atlas";
      user = {
        name = username;
        groups = [ "wheel" "docker" "gamemode" "networkmanager" ];
        defaultShell = "fish";
      };
      hyprland = {
        enable = true;
        autologin = true;
        bluetooth.enable = true;
      };
      noctalia = {
        enable = true;
        # noctalia config export > machines/atlas/noctalia/config.toml
        configFile = ./noctalia/config.toml;
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
