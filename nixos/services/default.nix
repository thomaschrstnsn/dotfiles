{ pkgs, config, lib, ... }:

{
  imports = [
    ./cloudflared.nix
    ./nats.nix
  ];
}
