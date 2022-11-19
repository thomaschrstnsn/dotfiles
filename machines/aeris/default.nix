{ systems, ... }:
{
  home = {
    user = rec {
      username = "thomas";
      homedir = "/Users/${username}";
    };
    dotnet = {
      enable = true;
      sdks = [ "6.0" ];
    };
    git.enable = true;
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
    zsh = {
      enable = true;
      editor = "nvim";
    };
  };

  darwin = {
    homebrew = {
      enable = true;
      extraCasks = [
        "brave-browser"
      ];
    };
    skhd = {
      enable = true;
      browser = "Brave Browser";
      useOpenForAppShortcuts = false;
      extraAppShortcuts = {
        "hyper - r" = "Rider";
        "hyper - u" = "Inkdrop";
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
    rnix-lsp
    nixpkgs-fmt
  ];

  system = systems.m1-darwin;
}
