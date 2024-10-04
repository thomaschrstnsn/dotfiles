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
      theme = "rose-pine";
    };
    wezterm = { enable = true; fontsize = 15.2; };
    zsh = {
      enable = true;
      editor = "nvim";
    };
  };

  darwin = {
    aerospace.enable = true;
    homebrew = {
      enable = true;
      extraBrews = [
        "docker-compose"
        "unixodbc"
        "msodbcsql17"
        "mssql-tools"
      ];
      extraCasks = [
        "arc"
        "bitwarden"
        "istat-menus@6"
        "jetbrains-toolbox"
        "logseq"
        "todoist"
      ];
      extraTaps = [ "microsoft/mssql-release" ];
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
