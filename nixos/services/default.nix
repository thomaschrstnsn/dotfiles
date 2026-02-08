{ pkgs, config, lib, ... }:

{
  imports = [
    ./cloudflared.nix
    ./screentime-web.nix
    ./timekpr-collector.nix
  ];
}
