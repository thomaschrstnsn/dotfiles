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
    ./realise_symlink.nix
    ./sesh.nix
    ./smd_launcher.nix
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
