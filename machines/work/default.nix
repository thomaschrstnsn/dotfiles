{ sshKeys, ... }:
let
  username = "tfc";
  personal = {
    userEmail = "thomas@chrstnsn.dk";
    userName = "Thomas Christensen";
    gpgVia1Password.key = sshKeys.personal.signing.publicKey;
    publicKeyFile = "~/.ssh/github-personal.pub";
  };
  logseq = {
    publicKeyFile = "~/.ssh/logseq-personal-deploy_ed25519";
  };
  zkPersonal = {
    publicKeyFile = "~/.ssh/zk.personal-deploy-key_ed25519";
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
      "~/zk.personal/" = zkPersonal;
    };
  };
in
{
  home = [{
    user = {
      inherit username;
      homedir = "/Users/${username}";
    };
    azure.enable = true;
    direnv.enable = true;
    dotnet = {
      enable = true;
      sdks = [ "8.0" "9.0" ];
    };
    fish.enable = true;
    nodejs.enable = true;
    git = {
      enable = true;
      mergiraf.enable = true;
    } // { inherit (vcs) alternativeConfigs; } // vcs.primaryConfig;
    ghostty = {
      enable = true;
      font.size = 14;
      font.family = "Maple Mono NF";
      windowBackgroundOpacity = 0.90;
      package = null;
      shaders = [ "cursor_blaze_tapered" ];
    };
    jj = {
      enable = true;
      meld.enable = true;
    } // { inherit (vcs) alternativeConfigs; } // vcs.primaryConfig;
    rancher.enable = true;
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
      hosts = [ "rpi4" "aero-nix" "enix" "rsync.net" "mft-az" ];
      includes = [ "personal_config" ];
      publicKeys = {
        "github-mft.pub" = sshKeys.mft.access.publicKey;
        "github-personal.pub" = sshKeys.personal.access.publicKey;
      };
    };
    python.enable = true;
    rust.enable = true;
    lazyvim = {
      colorscheme = "everforest";
      enable = true;
      copilot.enable = true;
      gh.enable = true;
      lang = {
        python.enable = true;
        markdown.enable = true;
        markdown.zk.enable = true;
        typescript.enable = true;
      };
    };
    ideavim.enable = true;
    tmux = {
      enable = true;
      theme = "rose-pine";
      aiAgent.enable = true;
    };
  }];

  darwin = {
    nix.daemon.enable = false; # determinate nix provides its own
    aerospace = {
      enable = true;
      hideMenuBar = false;
    };
    jankyborders.enable = true;
    homebrew = {
      enable = true;
      extraBrews = [
        "Azure/kubelogin/kubelogin"
      ];
      extraCasks = [
        "arc"
        "chatgpt"
        "ghostty"
        "istat-menus@6"
        "jetbrains-toolbox"
        "logseq"
        "meetingbar"
        "rancher"
        "webcatalog"
      ];
      extraTaps = [
        "Azure/kubelogin"
      ];
    };
    skhd = {
      enable = true;
      browser = "Arc";
      terminal = "ghostty";
      opener = "aetc";
      extraAppShortcuts = {
        "hyper - c" = "Microsoft Teams";
        "hyper - g" = "ChatGPT";
        "hyper - i" = "Microsoft Outlook";
        "hyper - r" = "Rider";
        "hyper - u" = "Logseq";
        "hyper - z" = "Spotify";
        "hyper - p" = "todoist";
        "hyper - v" = "Azure VPN Client";
      };
      extraShortcuts = { };
      prefixShortcuts = {
        leadingShortcut = "hyper - 9";
        appShortcuts = {
          # c = "Calendar";
        };
      };
    };
  };

  extraPackages = pkgs: with pkgs; [
    bacon
    devenv
    natscli
    opencode
    myPkgs.github-copilot-cli
    # kubernetes tools
    kubectl
    k9s
    # kubelogin
  ];

  system = "aarch64-darwin";
}
