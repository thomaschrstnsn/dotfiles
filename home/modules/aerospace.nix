{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.aerospace;
in
{
  options.tc.aerospace = {
    enable = mkEnableOption "aerospace tiling window manager config file";
  };

  config = mkIf cfg.enable {
    home.file = {
      ".config/aerospace/aerospace.toml".text = (readFile ./aerospace/aerospace.toml);
    };
  };
}
