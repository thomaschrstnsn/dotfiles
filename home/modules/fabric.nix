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
        fabric-describe-pattern = ''
          set -l pattern $argv[1]
          if test -z "$pattern"
              echo "Usage: fabric-describe-pattern <pattern>"
              return 1
          end
          set -l pattern_file "$HOME/.config/fabric/patterns/$pattern/system.md"
          if test -f "$pattern_file"
              cat "$pattern_file"
          else
              echo "Pattern '$pattern' not found at '$pattern_file'"
              return 1
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
      completions = {
        fabric-describe-pattern = ''
          function __fish_fabric_patterns
              set -l patterns_dir "$HOME/.config/fabric/patterns"
              if test -d "$patterns_dir"
                  for path in "$patterns_dir"/*/
                      if test -d "$path"
                          basename "$path"
                      end
                  end
              end
          end
          complete -c fabric-describe-pattern -f -a "(__fish_fabric_patterns)"
        '';
      };

    };

    xdg.configFile."fish/completions/fabric.fish" = { source = "${pkgs.fabric-ai}/share/fish/vendor_completions.d/fabric.fish"; };
  };
}

