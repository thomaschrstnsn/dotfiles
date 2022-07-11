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

  options.tc.user = with types; {
    username = mkOption {
      type = str;
    };
    homedir = mkOption {
      type = nullOr str;
    };
  };

  config = {
    home = {
      packages = with pkgs; [ git-crypt ];
      username = cfg.username;
    } // mkIf (cfg.homedir != null) {
      homeDirectory = cfg.homedir;
    };
  };
}
