{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.zsh;
  ssh-cfg = config.tc.ssh;
in
{
  options.tc.zsh = with types; {
    enable = mkEnableOption "zsh with settings";

    editor = mkOption {
      description = "Set $EDITOR (for cmdline git etc)";
      type = str;
      default = "nvim";
    };
    extraAliases = mkOption {
      description = "Extra aliases for zsh";
      type = attrs;
      default = { };
    };
    vi-mode.enable = mkOption {
      description = ''use vi-mode: https://github.com/jeffreytse/zsh-vi-mode'';
      type = bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {

    home.packages = with pkgs; [
      zsh-fzf-tab
    ];

    programs.zsh = {
      enable = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      initExtra = ''
        export PATH=~/bin:$PATH

        source ${pkgs.zsh-forgit}/share/zsh/zsh-forgit/forgit.plugin.zsh

        export EDITOR="${cfg.editor}"

        # term title
        export ZSH_THEME_TERM_TITLE_IDLE="%~"

        # ZSH COMPLETION CASE (IN)SENSITIVE
        zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

        # zsh-fzf-tab
        source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh

        if [[ -e ~/.env ]]; then
          source ~/.env
        fi

        # https://github.com/Aloxaf/fzf-tab/tree/7e0eee64df6c7c81a57792674646b5feaf89f263#configure
        zstyle ':completion:*:git-checkout:*' sort false
        zstyle ':completion:*:descriptions' format '[%d]'
        zstyle ':fzf-tab:complete:cd:*' fzf-preview 'exa -1 --color=always $realpath'
        zstyle ':fzf-tab:*' switch-group ',' '.'

        function killport() { lsof -i TCP:$1 | grep LISTEN | awk '{print $2}' | xargs kill -9 }
      '' + (if cfg.vi-mode.enable
      then ''
        # https://github.com/atuinsh/atuin/issues/977
        zvm_after_init_commands+=(eval "$(atuin init zsh)")
        bindkey '^r' atuin-search
        source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
      ''
      else "")
      + (if ssh-cfg.agent.enable
      then ''
        zstyle :omz:plugins:ssh-agent lazy yes 
        zstyle :omz:plugins:ssh-agent agent-forwarding yes
      ''
      else "");
      shellAliases = mkMerge [
        (mkIf true {
          cat = "${pkgs.bat}/bin/bat";
          man = "batman";
          reload_zshrc = "source ~/.zshrc";
        })
        {
          format-for-sql = ''awk '{printf "|%s|,\n", $1}' | sed "s/|/'/g"'';
          ndjson-to-jsonarray = "sed '1 s/^/[/ ; 2,$ s/^/,/; $ s/$/]/'";
          agenix = ''nix run github:ryantm/agenix --'';
          gtime = ''${pkgs.time}/bin/time'';
        }
        cfg.extraAliases
      ];

      oh-my-zsh = {
        enable = true;
        plugins = [
          "extract"
          "git"
          "history-substring-search"
          "zsh-interactive-cd"
        ] ++ (if ssh-cfg.agent.enable then [ "ssh-agent" ] else [ ]);
      };
    };
  };
}
