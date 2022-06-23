{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.user;
in
{
  imports = [
    ./aws.nix
    ./direnv.nix
    ./dotnet.nix
    ./git.nix
    ./nodejs.nix
    ./smd_launcher.nix
    ./tmux.nix
    ./zsh.nix

    ./haskell
  ];

  options.tc.user = {
    username = mkOption {
      type = types.str;
    };
    homedir = mkOption {
      type = types.str;
    };
  };

  config = {
    home.packages = with pkgs; [ git-crypt ];
    home.username = cfg.username;
    home.homeDirectory = cfg.homedir;
  };
}
