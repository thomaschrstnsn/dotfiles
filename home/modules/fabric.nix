{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.fabric;
in
{
  options.tc.fabric = with types; {
    enable = mkEnableOption "fabric-ai";
  };

  config = mkIf cfg.enable {
    programs.fabric-ai.enable = true;

    home.packages = with pkgs; [ yt-dlp ];

    programs.fish.functions = {
      ai = ''string join " " $argv | fabric -p ai'';
    };

    xdg.configFile."fish/completions/fabric.fish" = { source = "${pkgs.fabric-ai}/share/fish/vendor_completions.d/fabric.fish"; };
  };
}

