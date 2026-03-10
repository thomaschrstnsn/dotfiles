{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.fabric;
  jjCfg = config.tc.jj;

  prompt = ''
    You are an expert developer. Analyze the following git diff and write a commit message.
    Output a maximum 100 character title using a conventional commits prefix (feat/fix/chore/docs/refactor/perf/test/ci/build/style/revert).
    Then write a CHANGES section with 3-7 concise bullets (7-10 words each).
    Use imperative mood. Output only the commit message, no preamble or commentary.'';

  jj-ai-describe = pkgs.writeShellApplication {
    name = "jj-ai-describe";
    runtimeInputs = with pkgs;
      [ jujutsu ]
      ++ lib.optional (cfg.aiBackend == "fabric")  fabric-ai
      ++ lib.optional (cfg.aiBackend == "claude")  claude-code
      ++ lib.optional (cfg.aiBackend == "opencode") opencode;
    text = ''
      if [ $# -ne 1 ]; then
        echo "Usage: jj-ai-describe <revision>"
        exit 1
      fi
      ${lib.optionalString (cfg.aiBackend == "fabric") ''
        jj diff --git -r "$1" | fabric -p summarize_git_diff
      ''}
      ${lib.optionalString (cfg.aiBackend == "claude") ''
        jj diff --git -r "$1" | claude -p --system-prompt ${lib.escapeShellArg prompt} --tools "" --dangerously-skip-permissions
      ''}
      ${lib.optionalString (cfg.aiBackend == "opencode") ''
        DIFF=$(jj diff --git -r "$1")
        TMPFILE=$(mktemp /tmp/jj-diff-XXXXXX.patch)
        trap 'rm -f "$TMPFILE"' EXIT
        printf '%s' "$DIFF" > "$TMPFILE"
        opencode run ${lib.escapeShellArg prompt} -f "$TMPFILE"
      ''}
    '';
  };
in
{
  options.tc.fabric = with types; {
    enable = mkEnableOption "fabric-ai";

    aiBackend = mkOption {
      type = types.enum [ "fabric" "claude" "opencode" ];
      default = "fabric";
      description = "AI backend used by jj-ai-describe for commit message generation.";
    };
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
