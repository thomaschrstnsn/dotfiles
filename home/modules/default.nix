{ pkgs, config, lib, ... }:

{
  imports = [
    ./aws.nix
    ./direnv.nix
    ./dotnet.nix
    ./git.nix
    ./home.nix
    ./nodejs.nix
    ./rancher.nix
    ./ssh.nix
    ./smd_launcher.nix
    ./tmux.nix
    ./vim.nix
    ./wezterm.nix
    ./zsh.nix

    ./haskell
  ];
}
