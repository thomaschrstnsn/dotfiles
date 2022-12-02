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
    git.enable = true;
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
      networking.hostname = "DESKTOP-IP1G00V";
    };
    base = {
      imports = [
        ./configuration.nix
      ];
    };
  };
}
