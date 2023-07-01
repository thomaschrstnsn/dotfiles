{ systems, skhd-scripts, ... }:

{
  home = rec {
    user = rec {
      username = "thomaschrstnsn";
      homedir = "/Users/${username}";
    };

    aws.enable = true;
    direnv.enable = true;
    dotnet = {
      enable = true;
      sdks = [ "6.0" "7.0" ];
    };
    git = {
      enable = true;
      userEmail = "thomas@chrstnsn.dk";
    };
    nodejs = {
      enable = true;
      pkg = pkgs: pkgs.nodejs-18_x;
    };
    rancher = {
      enable = true;
    };
    ssh = {
      enable = true;
      use1PasswordAgentOnMac = true;
      hosts = [ "rpi4" ];
    };
    smd_launcher.enable = true;
    vim = {
      enable = true;
      ideavim = true;
    };
    wezterm.enable = true;
    zsh = {
      editor = "nvim";
      enable = true;
      extraAliases = { };
    };
  };

  darwin = {
    homebrew = {
      enable = true;
      extraTaps = [ "Microsoft/homebrew-mssql-release" ];
      extraBrews = [
        "docker-compose"
        "microsoft/mssql-release/mssql-tools" # 🤦‍♂️ first time install, you need to type: "YES" + enter while the prompt: "Installing microsoft/mssql-release/mssql-tools" is present
      ];
      extraCasks = [
        "asana"
        "azure-data-studio"
        "brave-browser"
        "google-drive"
        "jetbrains-toolbox"
        "meetingbar"
        "microsoft-edge"
        "microsoft-remote-desktop"
        "obsidian"
      ];
    };
    skhd = {
      enable = true;
      browser = "Microsoft Edge";
      terminal = "WezTerm";
      useOpenForAppShortcuts = false;
      extraAppShortcuts = {
        "hyper - z" = "zoom.us";
        "hyper - c" = "Slack";
        "hyper - u" = "Obsidian";
        "hyper - g" = "Google Chrome";
        "hyper - h" = "Brave Browser";
        "hyper - d" = "Azure Data Studio";
        "hyper - 0x32" = "Asana"; # >/<
        "hyper - y" = "Microsoft Remote Desktop";
      };
      extraAppShortcutsOnlySwitch = {
        "hyper - v" = "VMWare Fusion";
        "hyper - r" = "JetBrains Rider";
      };
      extraShortcuts = {
        "hyper - 0" = "alacritty --working-directory ~/bin -e zsh -c ~/bin/smd"; # smd-launcher
      };
      prefixShortcuts = {
        leadingShortcut = "hyper - 9";
        appShortcuts = { };
        shortcuts = { };
      };
    };
    sketchybar = {
      enable = true;
      scale = "desktop";
      position = "top";
      aliases.appgate.enable = true;
      aliases.meetingbar.enable = true;
    };
    yabai.enable = false; # does not build cleanly on gha
  };

  extraPackages = pkgs: with pkgs; [
    gh
    gum
    shellcheck
    rnix-lsp
    nixpkgs-fmt
    ripgrep

    glow
    visidata
  ];

  system = systems.x64-darwin;
}
