{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.ai;
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
      ++ lib.optional (cfg.backend == "claude") claude-code
      ++ lib.optional (cfg.backend == "opencode") opencode;
    text = ''
      if [ $# -ne 1 ]; then
        echo "Usage: jj-ai-describe <revision>"
        exit 1
      fi
      ${lib.optionalString (cfg.backend == "claude") ''
        jj diff --git -r "$1" | claude -p --system-prompt ${lib.escapeShellArg commitPrompt} --tools "" --dangerously-skip-permissions
      ''}
      ${lib.optionalString (cfg.backend == "opencode") ''
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
      ++ lib.optional (cfg.backend == "fabric") fabric-ai
      ++ lib.optional (cfg.backend == "claude") claude-code
      ++ lib.optional (cfg.backend == "opencode") opencode;
    text = ''
      if [ $# -ne 1 ]; then
        echo "Usage: jj-ai-pr-describe <revision>"
        exit 1
      fi
      REV=$1
      # trunk() may have multiple bookmarks; prefer main/master, otherwise take the first
      TRUNK=$(jj log -T 'self.local_bookmarks().map(|b| b.name() ++ "\n")' --no-graph --color=never -r 'trunk()' \
        | grep -m1 -E '^(main|master)$' \
        || jj log -T 'self.local_bookmarks().map(|b| b.name() ++ "\n")' --no-graph --color=never -r 'trunk()' \
        | grep -m1 .)
      ${lib.optionalString (cfg.backend == "claude") ''
        jj diff --from "heads(::$REV & ::$TRUNK)" --to "$REV" --git \
          | claude -p --system-prompt ${lib.escapeShellArg prPrompt} --tools "" --dangerously-skip-permissions
      ''}
      ${lib.optionalString (cfg.backend == "opencode") ''
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
  options.tc.ai = with types; {
    enable = mkEnableOption "ai" // { default = true; };

    backend = mkOption {
      type = types.enum [ "claude" "opencode" ];
      description = "AI backend used by CLI tools";
    };
  };

  config = mkIf cfg.enable {
    home.packages = lib.optionals jjCfg.enable [ jj-ai-describe jj-ai-pr-describe ];
  };
}
