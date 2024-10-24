{ pkgs, config, lib, ... }:

{
  imports = [
    ./aerospace.nix
    ./aws.nix
    ./check-terminal-color-and-fonts.nix
    ./direnv.nix
    ./dotnet.nix
    ./git.nix
    ./home.nix
    ./jujutsu.nix
    ./nodejs.nix
    ./rancher.nix
    ./realise_symlink.nix
    ./sesh.nix
    ./ssh.nix
    ./sway.nix
    ./tmux.nix
    ./vim.nix
    ./wezterm.nix
    ./wsl.nix
    ./zsh.nix

    ./haskell
  ];
}
