{ pkgs, config, lib, ... }:

{
  imports = [
    ./bootstrap.nix
    ./networking.nix
    ./user.nix
    ./vscode-server.nix
  ];
}
