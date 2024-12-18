{ systems, ... }:
{
  home = {
    user = rec {
      username = "tfc";
      homedir = "/Users/${username}";
    };
    aerospace.enable = true;
    aws.enable = true;
    direnv.enable = true;
    dotnet = {
      enable = true;
      sdks = [ "7.0" "8.0" "9.0"];
    };
    git = {
      enable = true;
      githubs = [ ];
      userEmail = "tfc@lindcapital.com";
      gpgVia1Password = true;
    };
    jj = {
      enable = true;
      userEmail = "tfc@lindcapital.com";
      gpgVia1Password = true;
    };
    ssh = {
      enable = true;
      use1PasswordAgent = true;
      hosts = [ "rpi4" "vmnix" "aero-nix" "enix" "rsync.net" "logseq-personal-deploy" ];
      includes = [ "personal_config" ];
      addLindHosts = true;
    };
    rancher.enable = true;
    vim = {
      enable = true;
      ideavim = true;
      lsp.servers.javascript = true;
      lsp.servers.python = true;
      lsp.servers.roslyn = true;
      # splitNavigator = "smart-splits";
    };
    tmux = {
      enable = true;
      disableAutoStarting = true;
      session-tool = "sesh";
      theme = "rose-pine";
    };
    wezterm = {
      enable = true;
      fontsize = 15.2;
      mux = false;
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
        "docker-compose"
      ];
      extraCasks = [
        "arc"
        "bitwarden"
        "istat-menus@6"
        "jetbrains-toolbox"
        "logseq"
        "todoist"
      ];
      extraTaps = [ ];
    };
    jankyborders.enable = true;
    skhd = {
      enable = true;
      browser = "Arc";
      terminal = "WezTerm";
      extraAppShortcuts = {
        "hyper - c" = "Microsoft Teams";
        "hyper - d" = "Azure Data Studio";
        "hyper - i" = "Microsoft Outlook";
        "hyper - r" = "Rider";
        "hyper - s" = "Self-Service";
        "hyper - u" = "Logseq";
        "hyper - y" = "Microsoft Remote Desktop";
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
  ];

  system = systems.m1-darwin;
}
