{ pkgs, config, lib, ... }:

{
  imports = [
    ./aws.nix
    ./direnv.nix
    ./dotnet.nix
    ./git.nix
    ./home.nix
    ./nodejs.nix
    ./ssh.nix
    ./smd_launcher.nix
    ./tmux.nix
    ./zsh.nix

    ./haskell
  ];
}
