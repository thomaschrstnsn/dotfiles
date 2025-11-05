{ pkgs, config, lib, inputs, ... }:

{
  imports = [
    ./aws.nix
    ./azure.nix
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
    ./rust.nix
    ./rancher.nix
    ./scripts.nix
    ./sesh.nix
    ./shell.nix
    ./ssh.nix
    ./sway.nix
    ./tmux.nix
    ./waybar.nix
    ./webapps.nix
    ./wezterm.nix
    ./wsl.nix
    ./yazi.nix
    ./zk.nix
    ./zsh.nix
  ];
}
