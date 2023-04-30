{ systems, ... }:
{
  home = {
    user = rec {
      username = "thomas";
      homedir = "/Users/${username}";
    };
    dotnet = {
      enable = true;
      sdks = [ "7.0" ];
    };
    git = {
      enable = true;
      githubs = [ ];
    };
    haskell.stack.enable = true;
    haskell.ihp.enable = true;
    ssh = {
      enable = true;
      use1PasswordAgentOnMac = true;
      hosts = [ "rpi4" "vmnix" "aero-nix" ];
      includes = [ "personal_config" ];
    };
    smd_launcher.enable = true;
    vim.enable = true;
    tmux.enable = true;
    wezterm = { enable = true; };
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
        "brave-browser"
        "google-drive"
        "obsidian"
      ];
    };
    skhd = {
      enable = true;
      browser = "Brave Browser";
      terminal = "WezTerm";
      useOpenForAppShortcuts = false;
      extraAppShortcuts = {
        "hyper - r" = "Rider";
        "hyper - u" = "Obsidian";
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
      enable = true;
      scale = "laptop";
      position = "top";
    };
    yabai.enable = true;
  };

  extraPackages = pkgs: with pkgs; [
    shellcheck
    nixpkgs-fmt
    rnix-lsp

    glow
    visidata
  ];

  system = systems.m1-darwin;
}
