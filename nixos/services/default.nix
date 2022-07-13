{ pkgs, config, lib, ... }:

{
  imports = [
    ./cloudflared.nix
  ];
}
