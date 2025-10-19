{ sshKeys, ... }:

let
  username = "thomas";
in
{
  home = [{
    user = {
      inherit username;
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
      gpgVia1Password.enable = true;
      gpgVia1Password.key = sshKeys.personal.signing.publicKey;
      publicKeyFile = "~/.ssh/github-personal.pub";
      alternativeConfigs = {
        "~/logseq.personal/" = { publicKeyFile = "~/.ssh/logseq-personal-deploy_ed25519"; };
      };
    };
    ghostty = {
      enable = true;
      fontsize = 15;
      shaders = [ "cursor_blaze_tapered" ];
      windowBackgroundOpacity = 0.7;
      package = null;
    };
    jj = {
      enable = true;
      gpgVia1Password.enable = true;
      gpgVia1Password.key = sshKeys.personal.signing.publicKey;
      publicKeyFile = "~/.ssh/github-personal.pub";
    };
    python.enable = true;
    rust.enable = true;
    ssh = {
      enable = true;
      _1password = {
        enableAgent = true;
        keys = [
          sshKeys.personal.access._1passwordId
          sshKeys.personal.signing._1passwordId
        ];
      };
      hosts = [ "rpi4" "aero-nix" "enix" "rsync.net" "cyrus" ];
      includes = [ "personal_config" ];
      publicKeys = {
        "github-personal.pub" = sshKeys.personal.access.publicKey;
      };
    };
    lazyvim = {
      colorscheme = "everforest";
      enable = true;
      lang.markdown.notes.enable = true;
    };
    ideavim.enable = true;
    tmux = {
      enable = true;
      theme = "rose-pine";
    };
  }];

  darwin = {
    aerospace = {
      enable = true;
      hideMenuBar = true;
    };
    homebrew = {
      enable = true;
      extraBrews = [
        "exiv2"
        "graelo/tap/pumas"
        "sst/tap/opencode"
      ];
      extraCasks = [
        "arc"
        "ghostty"
        "google-drive"
        "istat-menus@6"
        "karabiner-elements"
        "logseq"
      ];
      extraTaps = [
        "graelo/tap" # pumas
        "sst/tap" #opencode
      ];
    };
    jankyborders.enable = true;
    skhd = {
      enable = true;
      opener = "aetc";
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

  system = "aarch64-darwin";
}
