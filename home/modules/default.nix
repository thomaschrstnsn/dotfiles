{ pkgs, config, lib, inputs, ... }:

{
  imports = [
    ./aerospace.nix
    ./aws.nix
    ./check-terminal-color-and-fonts.nix
    ./direnv.nix
    ./dotnet.nix
    ./git.nix
    ./home.nix
    ./hyprland.nix
    ./jujutsu.nix
    ./nodejs.nix
    ./nushell.nix
    ./python.nix
    ./rancher.nix
    ./realise_symlink.nix
    ./sesh.nix
    ./shell.nix
    ./ssh.nix
    ./sway.nix
    ./tmux.nix
    ./vim.nix
    ./waybar.nix
    ./wezterm.nix
    ./wsl.nix
    ./yazi.nix
    ./zsh.nix
  ];
}
