{ pkgs, lib, ... }:

{
  fonts = {
    packages = with pkgs; [
      maple-mono.NF-unhinted
    ];
  };
}
