{ inputs, sshKeys, ... }:

let
  system = "x86_64-linux";
in
{
  home = [{
    user = {
      username = "thomas";
      homedir = "/home/thomas";
    };
    direnv.enable = true;
    ssh = {
      enable = true;
      publicKeys = {
        "github-personal.pub" = sshKeys.personal.access.publicKey;
      };
    };
    fish.enable = true;
    git = {
      enable = true;
      publicKeyFile = "~/.ssh/github-personal.pub";
    };
    jj = {
      enable = true;
      publicKeyFile = "~/.ssh/github-personal.pub";
    };
    ghostty = {
      enable = true;
      font.size = 13;
      windowBackgroundOpacity = 0.95;
      lightAndDarkMode.enable = false;
      # package = inputs.ghostty.packages.${system}.default;
      shaders = [ "cursor_blaze_tapered" ];
    };
    rust = {
      enable = true;
      linker = "mold";
    };
    tmux = {
      enable = true;
      remote = true;
      theme = "rose-pine";
    };
    lazyvim = {
      colorscheme = "kanagawa";
      enable = true;
      lang.python.enable = true;
      lang.markdown.zk.enable = true;
    };
  }
    {
      user = {
        username = "conrad";
        homedir = "/home/conrad";
      };
      ghostty = {
        enable = true;
        font.size = 13;
        windowBackgroundOpacity = 0.95;
        lightAndDarkMode.enable = false;
        # package = inputs.ghostty.packages.${system}.default;
        shaders = [ "cursor_blaze_tapered" ];
      };
    }];
  extraPackages = pkgs: with pkgs; [
    devenv
    spotify
    qt5.qtwayland
    # webcord-vencord
    vesktop
    wine64
  ];

  system = system;

  nixos = {
    config = {
      networking.hostname = "cyrus";
      user = {
        name = "thomas";
        groups = [ "wheel" "docker" "gamemode" ];
        defaultShell = "fish";
      };
    };
    base = {
      imports =
        [
          ./hardware.nix
          ./configuration.nix
        ];
    };
  };
}
