{ systems, ... }:
let
  username = "thomas";
  configurationRoot = ./nixos/machines/aero-nix;
in
{
  home = {
    user = {
      username = username;
      homedir = "/home/${username}";
    };
    direnv.enable = true;
    dotnet = {
      enable = true;
      sdks = [ "6.0" ];
    };
    git.enable = true;
    ssh = {
      enable = true;
      hosts = [ "rpi4" "vmnix" ];
    };
    vim.enable = true;
    zsh = {
      enable = true;
      editor = "nvim";
    };
  };

  extraPackages = pkgs: with pkgs; [
    brave
    _1password-gui
    vscode
    dmenu
    wezterm
  ];

  nixos = {
    config = {
      user = {
        name = username;
        groups = [ "wheel" ];
      };
      networking.hostname = "aero-nix";
    };
    base = {
      imports = [
        ./configuration.nix
      ];
    };
  };

  system = systems.x64-linux;
}
