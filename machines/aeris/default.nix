{ systems, ... }:
{
  home = {
    user = rec {
      username = "thomas";
      homedir = "/Users/${username}";
    };
    direnv.enable = true;
    dotnet = {
      enable = true;
      sdks = [ "7.0" "8.0" ];
    };
    fish.enable = true;
    git = {
      enable = true;
      githubs = [ ];
      gpgVia1Password = true;
    };
    ghostty = {
      enable = true;
      fontsize = 15;
      windowBackgroundOpacity = 0.7;
    };
    jj = {
      enable = true;
      gpgVia1Password = true;
    };
    nushell.enable = true;
    python.enable = true;
    ssh = {
      enable = true;
      use1PasswordAgent = true;
      hosts = [ "rpi4" "vmnix" "aero-nix" "enix" "rsync.net" "logseq-personal-deploy" ];
      includes = [ "personal_config" ];
    };
    vim = {
      enable = true;
      copilot.enable = false;
      ideavim = true;
      codelldb.enable = false;
    };
    tmux = {
      enable = true;
      theme = "rose-pine";
    };
    wezterm = {
      enable = true;
      fontsize = 13;
      windowBackgroundOpacity = 0.7;
      textBackgroundOpacity = 0.6;
    };
    zsh.enable = true;
  };

  darwin = {
    aerospace.enable = true;
    homebrew = {
      enable = true;
      extraBrews = [ "exiv2" ];
      extraCasks = [
        "arc"
        # "ghostty" # cask is broken currently, installed from official diskimage
        "google-drive"
        "istat-menus@6"
        "logseq"
      ];
    };
    jankyborders.enable = true;
    skhd = {
      enable = true;
      browser = "Arc";
      terminal = "ghostty"; # "WezTerm"
      extraAppShortcuts = {
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
    lnav
  ];

  system = systems.m1-darwin;
}
