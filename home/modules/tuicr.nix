{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.tuicr;
in
{
  options.tc.tuicr = with types; {
    enable = mkEnableOption "tuicr (TUI for PR/code review)";

    package = mkOption {
      type = nullOr package;
      default = null;
      description = "The tuicr package to install. Comes from the tuicr flake input, so it has to be passed in from the machine config.";
      example = literalExpression "inputs.tuicr.packages.\${system}.default";
    };
  };

  config = mkIf cfg.enable {
    home.packages = optional (cfg.package != null) cfg.package;

    xdg.configFile."tuicr/config.toml".source =
      (pkgs.formats.toml { }).generate "tuicr-config.toml" {
        backend = "libgit2";
        comment_tab_width = 4;
        comment_vim = false;
        cursor_line = true;
        diff_view = "side-by-side";
        ignore_whitespace = true;
        leader = " ";
        mouse = true;
        no_update_check = false;
        relative_line_numbers = false;
        review_watch_interval_ms = 1000;
        scroll_offset = 5;
        show_file_list = true;
        single_file_view = false;
        transparent_background = true;
        wrap = false;

        comment_types = [
          { id = "note"; label = "question"; definition = "ask for clarification"; color = "yellow"; }
          { id = "suggestion"; definition = "possible improvements"; }
          { id = "issue"; definition = "problems to fix"; }
          { id = "praise"; definition = "positive feedback"; }
          { id = "nit"; label = "nitpick"; definition = "small optional tweaks"; color = "#d19a66"; }
        ];

        forge.comment_type_prefix = true;

        export = {
          intro = "I reviewed your code and have the following comments. Please address them.";
          scope_line = true;
          pr_metadata = true;
          comments_header = "## Local tuicr Comments";
          remote_comments_header = "## Existing GitHub Comments";
          legend = true;
        };
      };
  };
}
