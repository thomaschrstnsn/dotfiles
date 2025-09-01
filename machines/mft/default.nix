{ sshKeys, ... }:
let
  personal = {
    userEmail = "thomas@chrstnsn.dk";
    userName = "Thomas Christensen";
    gpgVia1Password.key = sshKeys.personal.signing.publicKey;
    publicKeyFile = "~/.ssh/github-personal.pub";
  };
  logseq = {
    publicKeyFile = "~/.ssh/logseq-personal-deploy_ed25519";
  };
  vcs = {
    primaryConfig = {
      userName = "Thomas Fisker Christensen";
      userEmail = "tfc@mft-energy.com";
      gpgVia1Password.enable = true;
      gpgVia1Password.key = sshKeys.mft.signing.publicKey;
      publicKeyFile = "~/.ssh/github-mft.pub";
    };
    alternativeConfigs = {
      "~/dotfiles/" = personal;
      "~/personal/" = personal;
      "~/logseq.personal/" = logseq;
    };
  };
in
{
  home = {
    user = rec {
      username = "tfc";
      homedir = "/Users/${username}";
    };
    azure.enable = true;
    direnv.enable = true;
    dotnet = {
      enable = true;
      sdks = [ "8.0" "9.0" ];
    };
    fish.enable = true;
    git = {
      enable = true;
      mergiraf.enable = true;
    } // { alternativeConfigs = vcs.alternativeConfigs; } // vcs.primaryConfig;
    ghostty = {
      enable = true;
      fontsize = 15;
      windowBackgroundOpacity = 0.70;
      package = null;
    };
    jj = {
      enable = true;
      meld.enable = true;
    } // { alternativeConfigs = vcs.alternativeConfigs; } // vcs.primaryConfig;
    ssh = {
      enable = true;
      _1password = {
        enableAgent = true;
        keys = [
          sshKeys.mft.access._1passwordId
          sshKeys.mft.signing._1passwordId
          sshKeys.personal.access._1passwordId
          sshKeys.personal.signing._1passwordId
        ];
      };
      hosts = [ "rpi4" "vmnix" "aero-nix" "enix" "rsync.net" "mft-az" ];
      includes = [ "personal_config" ];
      publicKeys = {
        "github-mft.pub" = sshKeys.mft.access.publicKey;
        "github-personal.pub" = sshKeys.personal.access.publicKey;
      };
    };
    python.enable = true;
    lazyvim = {
      enable = true;
      copilot.enable = true;
      lang.python.enable = true;
    };
    vim = {
      enable = false;
      copilot.enable = true;
      ideavim = true;
      lsp.servers.javascript = true;
      lsp.servers.python = true;
      lsp.servers.roslyn = true;
      scrolloff = 5;
    };
    tmux = {
      enable = true;
      theme = "rose-pine";
    };
  };

  darwin = {
    nix.daemon.enable = false; # determinate nix provides its own
    aerospace.enable = true;
    jankyborders.enable = true;
    homebrew = {
      enable = true;
      extraBrews = [ ];
      extraCasks = [
        "arc"
        "jetbrains-toolbox"
        "logseq"
        "webcatalog"
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
    bacon
    devenv
    opencode
    rustup
  ];

  system = "aarch64-darwin";
}
