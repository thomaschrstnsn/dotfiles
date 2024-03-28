{ systems, ... }:

let
  username = "nixos";
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
      sdks = [ "7.0" "8.0" ];
    };
    git = {
      enable = true;
      githubs = [ ];
    };
    ssh = {
      enable = true;
      hosts = [ "rpi4" ];
      agent.enable = true;
    };
    tmux = {
      enable = true;
    };
    vim.enable = true;
    wsl.enable = true;
    zsh = {
      enable = true;
      editor = "nvim";
    };
  };
  system = systems.x64-linux;

  nixos = {
    config = {
      user = {
        name = username;
        groups = [ "wheel" ];
      };
      networking.hostname = "Atlas";
    };
    base = {
      imports = [
        ./configuration.nix
      ];
    };
  };
}
