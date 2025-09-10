{ pkgs, config, lib, inputs, ... }:

{
  imports = [
    ./aws.nix
    ./azure.nix
    ./check-terminal-color-and-fonts.nix
    ./desktop.nix
    ./direnv.nix
    ./dotnet.nix
    ./fish.nix
    ./git.nix
    ./ghostty.nix
    ./home.nix
    ./hyprland.nix
    ./ideavim.nix
    ./jujutsu.nix
    ./lazyvim.nix
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
    ./waybar.nix
    ./wezterm.nix
    ./wsl.nix
    ./yazi.nix
    ./zsh.nix
  ];
}
