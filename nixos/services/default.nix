{ pkgs, config, lib, ... }:

{
  imports = [
    ./cloudflared.nix
    ./screentime-web.nix
    ./nats.nix
  ];
}
