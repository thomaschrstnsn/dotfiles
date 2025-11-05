{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.zk;
  lazyCfg = config.tc.lazyvim;
in
{
  options.tc.zk = with types; {
    enable = mkEnableOption "zk" // {
      default = lazyCfg.lang.markdown.zk.enable;
    };

    directory = mkOption {
      type = str;
      default = "$HOME/zk.personal/";
      description = "Directory for zk notes";
    };
  };

  config = mkIf cfg.enable {
    programs.zk = {
      inherit (cfg) enable;
      settings = {
        notebook.dir = cfg.directory;
        note = {
          language = "en";
          filename = "{{id}}-{{slug title}}";
          extension = "md";
          id-charset = "alphanum";
          id-length = 4;
          id-case = "lower";
        };
        group = {
          journal = {
            paths = [ "journal/daily" ];
            note = {
              filename = "{{format-date now}}";
              template = "daily.md";
            };
          };
        };
        format.markdown.hashtags = true;
        filter.recents = "--sort created- --created-after 'last two weeks'";
        alias = {
          # new change from head, fetch origin, abandon empty changes from head to main@origin, rebase onto main@origin
          fetch_and_prune = "jj des automatic && jj new -m automatic && jj git fetch && jj abandon 'trunk()::@ & empty()' && jj rebase -d 'trunk()'";
          # fetch and prune, move our bookmark (if needed) and push
          sync = "zk fetch_and_prune && jj tug ; jj git push";
          daily = ''zk new --no-input "$ZK_NOTEBOOK_DIR/journal/daily"'';
          offset = ''zk new --no-input "$ZK_NOTEBOOK_DIR/journal/daily" --date $(date -v $argv[1]d +%F)'';
          edlast = "zk edit --limit 1 --sort modified- $argv";
          recent = "zk edit --sort created- --modified-after 'last two weeks' --interactive";
          n = ''zk new --title "$argv"'';
          ls = "zk list";
          e = ''zk edit --interactive -m "$argv"'';
        };

        tool.fzf-preview = "bat -p --italic-text always --decorations always --color always {-1}";

        lsp = {
          diagnostics = {
            wiki-title = "hint";
            dead-link = "error";
          };
          completion = {
            # Show the note title in the completion pop-up, or fallback on its path if empty.
            note-label = "{{title-or-path}}";
            # Filter out the completion pop-up using the note title or its path.
            note-filter-text = "{{title}} {{path}}";
            # Show the note filename without extension as detail.
            note-detail = "{{filename-stem}}";
          };
        };
      };
    };

    programs.tmux.extraConfig = mkIf cfg.enable ''
      bind n run-shell ${tmux/zk-toggle.sh}
    '';

    home.sessionVariables = mkIf cfg.enable {
      ZK_NOTEBOOK_DIR = cfg.directory;
    };
  };
}
