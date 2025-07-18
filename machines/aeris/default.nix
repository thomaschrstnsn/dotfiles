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
      sdks = [ "8.0" "9.0" ];
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
      scrolloff = 5;
    };
    tmux = {
      enable = true;
      theme = "rose-pine";
    };
  };

  darwin = {
    aerospace.enable = true;
    homebrew = {
      enable = true;
      extraBrews = [ "sst/tap/opencode" "exiv2" ];
      extraCasks = [
        "arc"
        # "ghostty" # cask is broken currently, installed from official diskimage
        "google-drive"
        "istat-menus@6"
        "logseq"
      ];
      extraTaps = [
        "sst/tap" #opencode
      ];
    };
    jankyborders.enable = true;
    skhd = {
      enable = true;
      browser = "Arc";
      terminal = "ghostty";
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
