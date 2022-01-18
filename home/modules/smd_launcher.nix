{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.smd_launcher;
in
{
  options.tc.smd_launcher = {
    enable = mkEnableOption "smd-launcher";
  };

  config = mkIf (cfg.enable) {
    programs.alacritty = {
      enable = true;
      settings = {
        window = {
          dimensions = {
            columns = 110;
            lines = 30;
          };
          decorations = "none";
          title = "launcher";
        };
        font.size = 17;
      };
    };
  };
}
