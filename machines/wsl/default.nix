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
    git = {
      enable = true;
      githubs = [ ];
    };
    ssh = {
      enable = true;
      hosts = [ "rpi4" ];
    };
    wsl.enable = true;
    zsh = {
      enable = true;
      editor = "nvim";
    };
    vim.enable = true;
    direnv.enable = true;
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
