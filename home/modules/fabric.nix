{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.fabric;
  jjCfg = config.tc.jj;
in
{
  options.tc.fabric = with types; {
    enable = mkEnableOption "fabric-ai";
  };

  config = mkIf cfg.enable {
    programs.fabric-ai.enable = true;

    home.packages = with pkgs; [ yt-dlp ];

    programs.fish = {
      functions = mkMerge [{
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
      }
        (mkIf jjCfg.enable {
          jj-ai-describe = ''
            set -l rev $argv[1]
            if test -z "$rev"
                echo "Usage: jj-ai-describe <revision>"
                return 1
            end
            jj diff --git -r $rev | fabric -p summarize_git_diff
          '';
        })];
    };

    xdg.configFile."fish/completions/fabric.fish" = { source = "${pkgs.fabric-ai}/share/fish/vendor_completions.d/fabric.fish"; };
  };
}

