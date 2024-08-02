{ systems, ... }:
{
  home = {
    user = rec {
      username = "tfc";
      homedir = "/Users/${username}";
    };
    aws.enable = true;
    direnv.enable = true;
    dotnet = {
      enable = true;
      sdks = [ "6.0" "7.0" "8.0" ];
    };
    git = {
      enable = true;
      githubs = [ ];
      userEmail = "tfc@lindcapital.com";
      gpgVia1Password = true;
    };
    ssh = {
      enable = true;
      use1PasswordAgentOnMac = true;
      hosts = [ "rpi4" "vmnix" "aero-nix" "enix" "rsync.net" "logseq-personal-deploy" ];
      includes = [ "personal_config" ];
      addLindHosts = true;
    };
    vim = {
      enable = true;
      ideavim = true;
      lsp.servers.omnisharp = true;
      lsp.servers.javascript = true;
      lsp.servers.python = true;
      codelldb.enable = false;
    };
    tmux = {
      enable = true;
      session-tool = "sesh";
    };
    wezterm = { enable = true; };
    zsh = {
      enable = true;
      editor = "nvim";
    };
  };

  darwin = {
    ice.enable = true;
    homebrew = {
      enable = true;
      extraBrews = [
        "docker-compose"
      ];
      extraCasks = [
        "arc"
        "bitwarden"
        "jetbrains-toolbox"
        "logseq"
        "spaceman"
        "todoist"
      ];
    };
    skhd = {
      enable = true;
      browser = "Arc";
      terminal = "WezTerm";
      useOpenForAppShortcuts = false;
      extraAppShortcuts = {
        "hyper - c" = "Microsoft Teams";
        "hyper - d" = "Azure Data Studio";
        "hyper - i" = "Microsoft Outlook";
        "hyper - r" = "Rider";
        "hyper - s" = "Self-Service";
        "hyper - u" = "Logseq";
        "hyper - y" = "Microsoft Remote Desktop";
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
