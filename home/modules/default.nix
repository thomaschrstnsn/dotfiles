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
    ./sesh.nix
    ./smd_launcher.nix
    ./ssh.nix
    ./sway.nix
    ./tmux.nix
    ./vim.nix
    ./wsl.nix
    ./wezterm.nix
    ./zsh.nix

    ./haskell
  ];
}
