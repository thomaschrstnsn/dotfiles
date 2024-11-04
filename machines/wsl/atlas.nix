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
      hosts = [ "rpi4" "enix" "rsync.net" ];
      agent.enable = true;
    };
    tmux = {
      enable = true;
    };
    vim = {
      enable = true;
      codelldb.enable = true;
    };
    wsl.enable = true;
    zsh = {
      enable = true;
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
    isWsl = true;
    base = {
      imports = [
        ./configuration.nix
      ];
    };
  };
}
