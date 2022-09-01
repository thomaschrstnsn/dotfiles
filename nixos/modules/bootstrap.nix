{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [ ];

  programs = {
    zsh = {
      enable = true;
      promptInit = "";
    };
  };
}
