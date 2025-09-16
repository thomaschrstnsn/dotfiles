{ inputs, ... }:
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
      hosts = [ "rpi4" "enix" "rsync.net" ];
      agent.enable = true;
    };
    sway.enable = true;
    waybar.enable = true;
    tmux.enable = true;
    wezterm = {
      enable = true;
      fontsize = 11.5;
    };
    zsh = {
      enable = true;
    };
  };

  extraPackages = pkgs: with pkgs; [
    _1password-gui
    brave
    dmenu
    # obsidian
    # sonic-pi
    qt5.qtwayland

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

        inputs.nixos-hardware.nixosModules.apple-macbook-air-6
      ];
    };
  };

  system = "x86_64-linux";
}
