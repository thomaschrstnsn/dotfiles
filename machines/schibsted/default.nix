{ systems, skhd-scripts, ... }:

{
  home = rec {
    user = rec {
      username = "thomas.christensen@schibsted.com";
      homedir = "/Users/${username}";
    };

    aws.enable = true;
    direnv.enable = true;
    dotnet = {
      enable = true;
      sdks = [ "2.2" "3.1" "6.0" "7.0" ];
    };
    git = {
      enable = true;
      userEmail = user.username;
      githubs = [ "github.schibsted.io" ];
    };
    nodejs = {
      enable = true;
      pkg = pkgs: pkgs.nodejs-16_x;
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
    vim.enable = true;
    wezterm.enable = true;
    zsh = {
      editor = "nvim";
      enable = true;
      extraAliases = {
        meet-billing-and-reporting = ''"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --app=http://g.co/meet/billing-and-reporting &'';
        meet-browser = ''"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --app=http://g.co/meet/ &'';
      };
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
        # "shift - f14" = "osascript ${skhd-scripts}/toggle-mute-mic.applescript";
        # "cmd + shift - f14" = "say command";
        # "hyper - f14" = "say hyper";
        # "alt + shift - f14" = "say alt";
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
    yabai.enable = true;
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
