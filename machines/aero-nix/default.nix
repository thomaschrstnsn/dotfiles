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
      sdks = [ "7.0" ];
    };
    git.enable = true;
    ssh = {
      enable = true;
      hosts = [ "rpi4" "vmnix" ];
      agent.enable = true;
    };
    sway.enable = true;
    tmux.enable = true;
    vim.enable = true;
    zsh = {
      enable = true;
      editor = "nvim";
    };
  };

  extraPackages = pkgs: with pkgs; [
    _1password-gui
    brave
    dmenu
    obsidian
    # todoist-electron
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
