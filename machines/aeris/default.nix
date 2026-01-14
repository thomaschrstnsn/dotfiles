{ sshKeys, ... }:

let
  username = "thomas";

  alternative = {
    "~/zk.personal/" = { publicKeyFile = "~/.ssh/zk.personal-deploy-key_ed25519"; };
  };
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
    fabric.enable = true;
    fish.enable = true;
    git = {
      enable = true;
      gpgVia1Password.enable = true;
      gpgVia1Password.key = sshKeys.personal.signing.publicKey;
      publicKeyFile = "~/.ssh/github-personal.pub";
      alternativeConfigs = alternative;
    };
    ghostty = {
      enable = true;
      font.size = 14;
      font.family = "Maple Mono NF";
      shaders = [ "cursor_blaze_tapered" ];
      windowBackgroundOpacity = 0.7;
      package = null;
    };
    jj = {
      enable = true;
      gpgVia1Password.enable = true;
      gpgVia1Password.key = sshKeys.personal.signing.publicKey;
      publicKeyFile = "~/.ssh/github-personal.pub";
      alternativeConfigs = alternative;
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
      lang.markdown.zk.enable = true;
      gh.enable = true;
    };
    ideavim.enable = true;
    tmux = {
      enable = true;
      theme = "powerkit";
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
      ];
      extraCasks = [
        "arc"
        "ghostty"
        "google-drive"
        "istat-menus@6"
        "karabiner-elements"
      ];
      extraTaps = [
      ];
    };
    jankyborders.enable = true;
    skhd = {
      enable = true;
      browser = "Arc";
      terminal = "ghostty";
      extraAppShortcuts = {
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
    opencode
    lnav
  ];

  system = "aarch64-darwin";
}
