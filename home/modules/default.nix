{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.user;
in
{
  imports = [
    ./aws.nix
    ./dotnet.nix
    ./git.nix
    ./nodejs.nix
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
    home.username = cfg.username;
    home.homeDirectory = cfg.homedir;
  };
}
