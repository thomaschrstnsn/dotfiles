{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.nodejs;
in
{
  options.tc.nodejs = {
    enable = mkEnableOption "nodejs";

    pkg = mkOption {
      description = "Which pkg to use";
      default = pkgs: pkgs.nodejs_24;
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ (cfg.pkg pkgs) ];

    programs.zsh.oh-my-zsh.plugins = [ "node" "npm" ];
  };
}
