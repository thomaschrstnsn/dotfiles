{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.fabric;
  jjCfg = config.tc.jj;

  commitPrompt = ''
    You are an expert developer. Analyze the following git diff and write a commit message.
    Output a maximum 100 character title using a conventional commits prefix (feat/fix/chore/docs/refactor/perf/test/ci/build/style/revert).
    Then write a CHANGES section with 3-7 concise bullets (7-10 words each).
    Use imperative mood. Output only the commit message, no preamble or commentary.'';

  prPrompt = ''
    You are an expert developer. Analyze the following git diff and write a GitHub pull request description.
    Start with a concise one-sentence summary of what the PR does.
    Then write a ## Changes section with clear bullet points describing what changed and why.
    Then write a ## Notes section for anything a reviewer should be aware of (skip this section if there is nothing notable).
    Use imperative mood. Output only the PR description in Markdown, no preamble or commentary.'';

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
        jj diff --git -r "$1" | claude -p --system-prompt ${lib.escapeShellArg commitPrompt} --tools "" --dangerously-skip-permissions
      ''}
      ${lib.optionalString (cfg.aiBackend == "opencode") ''
        DIFF=$(jj diff --git -r "$1")
        TMPFILE=$(mktemp /tmp/jj-diff-XXXXXX.patch)
        trap 'rm -f "$TMPFILE"' EXIT
        printf '%s' "$DIFF" > "$TMPFILE"
        opencode run ${lib.escapeShellArg commitPrompt} -f "$TMPFILE"
      ''}
    '';
  };

  jj-ai-pr-describe = pkgs.writeShellApplication {
    name = "jj-ai-pr-describe";
    runtimeInputs = with pkgs;
      [ jujutsu ]
      ++ lib.optional (cfg.aiBackend == "fabric")  fabric-ai
      ++ lib.optional (cfg.aiBackend == "claude")  claude-code
      ++ lib.optional (cfg.aiBackend == "opencode") opencode;
    text = ''
      if [ $# -ne 1 ]; then
        echo "Usage: jj-ai-pr-describe <revision>"
        exit 1
      fi
      REV=$1
      TRUNK=$(jj log -T 'self.local_bookmarks()' -r 'trunk()')
      ${lib.optionalString (cfg.aiBackend == "fabric") ''
        jj diff --from "heads(::$REV & ::$TRUNK)" --to "$REV" --git | fabric -p write_pull-request
      ''}
      ${lib.optionalString (cfg.aiBackend == "claude") ''
        jj diff --from "heads(::$REV & ::$TRUNK)" --to "$REV" --git \
          | claude -p --system-prompt ${lib.escapeShellArg prPrompt} --tools "" --dangerously-skip-permissions
      ''}
      ${lib.optionalString (cfg.aiBackend == "opencode") ''
        DIFF=$(jj diff --from "heads(::$REV & ::$TRUNK)" --to "$REV" --git)
        TMPFILE=$(mktemp /tmp/jj-pr-diff-XXXXXX.patch)
        trap 'rm -f "$TMPFILE"' EXIT
        printf '%s' "$DIFF" > "$TMPFILE"
        opencode run ${lib.escapeShellArg prPrompt} -f "$TMPFILE"
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

    home.packages = with pkgs; [ yt-dlp ]
      ++ lib.optionals jjCfg.enable [ jj-ai-describe jj-ai-pr-describe ];

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
