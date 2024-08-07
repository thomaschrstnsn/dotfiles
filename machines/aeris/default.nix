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
    git = {
      enable = true;
      githubs = [ ];
      gpgVia1Password = true;
    };
    ssh = {
      enable = true;
      use1PasswordAgentOnMac = true;
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
      session-tool = "sesh";
    };
    wezterm = { enable = true; fontsize = 13; };
    zsh = {
      enable = true;
      editor = "nvim";
    };
  };

  darwin = {
    homebrew = {
      enable = true;
      extraBrews = [ "exiv2" ];
      extraCasks = [
        "arc"
        "google-drive"
        "logseq"
        "rustrover"
      ];
    };
    ice.enable = true;
    skhd = {
      enable = true;
      browser = "Arc";
      terminal = "WezTerm";
      useOpenForAppShortcuts = false;
      extraAppShortcuts = {
        "hyper - r" = "Rider";
        "hyper - u" = "Logseq";
        "hyper - z" = "Spotify";
      };
      extraShortcuts = { };
      prefixShortcuts = {
        leadingShortcut = "hyper - 9";
        appShortcuts = {
          c = "Calendar";
        };
      };
    };
    sketchybar = {
      enable = false;
    };
    yabai = {
      enable = true;
      jankyborders.enable = true;
    };
  };

  extraPackages = pkgs: with pkgs; [
    devenv
  ];

  system = systems.m1-darwin;
}
