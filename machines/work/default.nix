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
      enable = false; # disabled per an update that built the world for 22 mins...
      # dotnet-stage0-vmr>   [06.30.52.15] Building windowsdesktop...done
      # dotnet-stage0-vmr>   New artifact(s) after building windowsdesktop:
      # dotnet-stage0-vmr>     -> Microsoft.WindowsDesktop.App.Internal/10.0.3-servicing.26075.103
      # dotnet-stage0-vmr>     -> Microsoft.WindowsDesktop.App.Ref/10.0.3
      # dotnet-stage0-vmr>     -> WindowsDesktop/10.0.3-servicing.26075.103/productVersion.txt
      # dotnet-stage0-vmr>     -> WindowsDesktop/10.0.3-servicing.26075.103/windowsdesktop-productVersion.txt
      # dotnet-stage0-vmr>   DirSize After Building windowsdesktop
      # dotnet-stage0-vmr>   Filesystem      Size  Used Avail Use% Mounted on
      # dotnet-stage0-vmr>   /dev/disk3s7    461G  401G   60G  88% /nix
      # dotnet-stage0-vmr>   DirSize After CleanupRepo windowsdesktop
      # dotnet-stage0-vmr>   Filesystem      Size  Used Avail Use% Mounted on
      # dotnet-stage0-vmr>   /dev/disk3s7    461G  401G   60G  88% /nix
      sdks = [ "8.0" "9.0" "10.0" ];
    };
    fabric = {
      enable = true;
      aiBackend = "opencode";
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
      hosts = [ "rpi4" "cyrus" "enix" "rsync.net" "mft-az" ];
      includes = [ "personal_config" ];
      publicKeys = {
        "github-mft.pub" = sshKeys.mft.access.publicKey;
        "github-personal.pub" = sshKeys.personal.access.publicKey;
      };
    };
    python.enable = true;
    rust.enable = true;
    lazyvim = {
      colorscheme = "rose-pine";
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
        "meetingbar"
        "rancher"
        "vpnstatus"
        "webcatalog"
      ];
      extraTaps = [
        "Azure/kubelogin"
        "timac/vpnstatus"
      ];
    };
    mermaidCli.enable = true;
    skhd = {
      enable = true;
      browser = "Arc";
      terminal = "ghostty";
      extraAppShortcuts = {
        "hyper - c" = "Microsoft Teams";
        "hyper - g" = "Claude";
        "hyper - i" = "Microsoft Outlook";
        "hyper - z" = "Spotify";
        "hyper - p" = "todoist";
        "hyper - v" = "Azure VPN Client";
      };
      extraAppShortcutsOnlySwitch = {
        "hyper - r" = "JetBrains Rider";
      };
      extraShortcuts = { };
      prefixShortcuts = {
        leadingShortcut = "hyper - 9";
        appShortcuts = {
          # c = "Calendar";
        };
      };
    };
    sleepwatcher = {
      enable = true;
      bluetooth = {
        # autoConnectDevices = [ "c8-bc-c8-fc-fe-fc" ];
        powerOffOnSleep = true;
        powerOnOnWake = true;
      };
    };
  };

  extraPackages = pkgs: with pkgs; [
    bacon
    claude-code
    devenv
    kitty
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
