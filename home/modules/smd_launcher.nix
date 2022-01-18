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
            lines = 25;
            columns = 80;
          };
          font.size = 13;
          decorations = "none";
          title = "launcher";
        };
        shell.program = "htop";
        # working_directory = "~/bin";
      };
    };
  };
}
