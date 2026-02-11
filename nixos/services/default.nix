{ pkgs, config, lib, ... }:

{
  imports = [
    ./cloudflared.nix
    ./screentime-web.nix
    ./screentime-collector.nix
  ];
}
