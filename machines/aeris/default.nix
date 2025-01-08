{ systems, ... }:
{
  home = {
    user = rec {
      username = "thomas";
      homedir = "/Users/${username}";
    };
    aerospace.enable = true;
    direnv.enable = true;
    dotnet = {
      enable = true;
      sdks = [ "7.0" "8.0" ];
    };
    git = {
      enable = true;
      githubs = [ ];
      gpgVia1Password = true;
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
      ideavim = true;
      lsp.servers.omnisharp = true;
      codelldb.enable = false;
    };
    tmux = {
      enable = true;
    };
    wezterm = { enable = true; fontsize = 13; };
    zsh = {
      enable = true;
    };
  };

  darwin = {
    aerospace.enable = true;
    homebrew = {
      enable = true;
      extraBrews = [ "exiv2" ];
      extraCasks = [
        "arc"
        "google-drive"
        "istat-menus@6"
        "logseq"
      ];
    };
    jankyborders.enable = true;
    skhd = {
      enable = true;
      browser = "Arc";
      terminal = "WezTerm";
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
  ];

  system = systems.m1-darwin;
}
