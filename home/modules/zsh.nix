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
      default = "code --wait";
    };
    extraAliases = mkOption {
      description = "Extra aliases for zsh";
      type = attrs;
      default = { };
    };
    prompt = mkOption {
      type = enum [ "p10k" "starship" ];
      description = "Which prompt to use";
      default = "starship";
    };
    vi-mode.enable = mkOption {
      description = ''use vi-mode: https://github.com/jeffreytse/zsh-vi-mode'';
      type = bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {

    programs.starship = {
      enable = cfg.prompt == "starship";
      settings = {
        aws = {
          format = "on $symbol ($profile) ($style)";
          symbol = "";
        };
        directory = {
          truncation_symbol = "…/";
        };
      };
    };

    home.packages = with pkgs; [
      bottom
      du-dust
      lazydocker
      fd
      file
      jq
      tree
      wget
      zsh-fzf-tab
    ] ++ optional (cfg.prompt == "p10k") zsh-powerlevel10k;

    home.file = mkIf (cfg.prompt == "p10k") {
      ".p10k.zsh".source = ./zsh/p10k.zsh;
    };
    programs.zsh.initExtraBeforeCompInit =
      if cfg.prompt == "p10k"
      then ''
        source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
        source ~/.p10k.zsh
      ''
      else "";

    programs.eza = {
      enable = true;
      enableZshIntegration = true;
    };

    programs.bat = {
      enable = true;
      extraPackages = with pkgs.bat-extras; [ batman ];
      config.theme = "enki-tokyo-night";
      themes = {
        # enki: https://github.com/enkia/enki-theme
        enki-tokyo-night = {
          src = pkgs.fetchFromGitHub {
            owner = "enkia";
            repo = "enki-theme"; # Bat uses sublime syntax for its themes
            rev = "0b629142733a27ba3a6a7d4eac04f81744bc714f";
            sha256 = "sha256-Q+sac7xBdLhjfCjmlvfQwGS6KUzt+2fu+crG4NdNr4w=";
          };
          file = "scheme/Enki-Tokyo-Night.tmTheme";
        };
      };
    };

    programs.fzf = {
      enable = true;
      fileWidgetCommand = "fd --type f --type d --type symlink";
      defaultCommand = "fd --type f";
      changeDirWidgetCommand = "fd --type d";
    };

    programs.htop.enable = true;

    programs.btop = {
      enable = true;
    };

    programs.home-manager.enable = true;

    programs.atuin = {
      enable = true;
      # https://docs.atuin.sh/configuration/config/
      settings = {
        filter_mode_shell_up_key_binding = "directory";
        filter_mode = "global";
        search_mode_shell_up_key_binding = "fuzzy";
        search_mode = "fuzzy";
        style = "compact";
      };
    };

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
