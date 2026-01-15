{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.fabric;
  jjCfg = config.tc.jj;

  jj-ai-describe = pkgs.writeShellApplication {
    name = "jj-ai-describe";
    runtimeInputs = with pkgs; [ jujutsu fabric-ai ];
    text = ''
      if [ $# -ne 1 ]; then
        echo "Usage: jj-ai-describe <revision>"
        exit 1
      fi
      jj diff --git -r "$1" | fabric -p summarize_git_diff
    '';
  };
in
{
  options.tc.fabric = with types; {
    enable = mkEnableOption "fabric-ai";
  };

  config = mkIf cfg.enable {
    programs.fabric-ai.enable = true;

    home.packages = with pkgs; [ yt-dlp ] ++ lib.optional jjCfg.enable jj-ai-describe;

    programs.fish = {
      functions = {
        ai = ''string join " " $argv | fabric -p ai'';
        fabric-pattern = ''
          set -l patterns_dir "$HOME/.config/fabric/patterns"
          if not test -d "$patterns_dir"
            echo "Patterns directory not found: $patterns_dir"
            return 1
          end
          set -l pattern (ls "$patterns_dir" | fzf --preview "cat '$patterns_dir'/{}/system.md")
          if test -n "$pattern"
            bat "$patterns_dir/$pattern/system.md"
          end
        '';
      };
    };

    xdg.configFile."fish/completions/fabric.fish" = { source = "${pkgs.fabric-ai}/share/fish/vendor_completions.d/fabric.fish"; };
  };
}

