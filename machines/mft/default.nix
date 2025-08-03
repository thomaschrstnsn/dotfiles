{ ... }:
let
  email = "tfc@mft-energy.com";
in
{
  home = {
    user = rec {
      username = "tfc";
      homedir = "/Users/${username}";
    };
    direnv.enable = true;
    dotnet = {
      enable = true;
      sdks = [ "8.0" "9.0" ];
    };
    git = {
      enable = true;
      githubs = [ ];
      userName = "Thomas Fisker Christensen";
      userEmail = email;
      publicKeyFile = "~/.ssh/github-mft.pub";
      gpgVia1Password.enable = true;
      gpgVia1Password.key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINfb3NXjwOznbBFJ4QQ0WWmDrZncdHof4Y9VVZYrxX7J";
      alternativeConfig = {
        enable = true;
        paths = [ "~/dotfiles/" "~/personal/" ];
        userEmail = "thomas@chrstnsn.dk";
        userName = "Thomas Christensen";
        gpgVia1Password.key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIErz7lXsjPyJcjzRKMWyZodRGzjkbCxWu/Lqk+NpjupZ";
        publicKeyFile = "~/.ssh/github-personal.pub";
      };
    };
    ghostty = {
      enable = true;
      fontsize = 15;
      windowBackgroundOpacity = 0.7;
      package = null;
    };
    jj = {
      enable = true;
      userEmail = email;
      gpgVia1Password = true;
      meld.enable = true;
    };
    ssh = {
      enable = true;
      _1password = {
        enableAgent = true;
        keys = [ "abzfs445wgvufgybncdcjgptla" "6ddacbrzis56q7qmq5bkinjsum" "lksx2w2y2iewhnbbczk7lg4d2a" "uczvt65unrn2iqsshuvyuhysky" ];
      };
      hosts = [ "rpi4" "vmnix" "aero-nix" "enix" "rsync.net" "logseq-personal-deploy" ];
      includes = [ "personal_config" ];
      publicKeys = {
        "github-mft.pub" = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKOu8nwGPqqqz9fRAAGk7b9ZP5Y7kNd3u/efxUTGFeto";
        "github-personal.pub" = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICTvFy5gC46MnA0Eu+DoYQbldwxoJJVd9KVpAFwkS+ZH";
      };
    };
    python.enable = true;
    vim = {
      enable = true;
      ideavim = true;
      lsp.servers.javascript = true;
      lsp.servers.python = true;
      lsp.servers.roslyn = true;
      scrolloff = 5;
    };
    tmux = {
      enable = true;
      disableAutoStarting = true;
      theme = "rose-pine";
    };
    zsh = {
      enable = true;
      vi-mode.enable = false;
    };
  };

  darwin = {
    aerospace.enable = true;
    homebrew = {
      enable = true;
      extraBrews = [
      ];
      extraCasks = [
        "arc"
        "istat-menus@6"
        "jetbrains-toolbox"
        "logseq"
        "todoist"
      ];
      extraTaps = [ ];
    };
    skhd = {
      enable = true;
      browser = "Arc";
      terminal = "ghostty";
      extraAppShortcuts = {
        "hyper - c" = "Microsoft Teams";
        "hyper - d" = "Azure Data Studio";
        "hyper - i" = "Microsoft Outlook";
        "hyper - r" = "Rider";
        "hyper - u" = "Logseq";
        "hyper - z" = "Spotify";
        "hyper - p" = "todoist";
      };
      extraShortcuts = { };
      prefixShortcuts = {
        leadingShortcut = "hyper - 9";
        appShortcuts = {
          c = "Calendar";
        };
      };
    };
  };

  extraPackages = pkgs: with pkgs; [
    devenv
    rustup
  ];

  system = "aarch64-darwin";
}
