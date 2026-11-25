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
    ./hyprland
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
    ./tmux.nix
    ./tuicr.nix
    ./webapps.nix
    ./wezterm.nix
    ./wsl.nix
    ./yazi.nix
    ./zen.nix
    ./zk.nix
    ./zsh.nix
  ];
}
