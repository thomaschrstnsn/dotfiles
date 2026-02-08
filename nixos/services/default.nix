{ pkgs, config, lib, ... }:

{
  imports = [
    ./cloudflared.nix
    ./timekpr-collector.nix
  ];
}
