{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.zsh;
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
      description = "use vi-mode";
      type = bool;
      default = true;
    };
  };

  config = mkIf (cfg.enable) {

    programs.starship = {
      enable = cfg.prompt == "starship";
      settings = {
        aws = {
          disabled = true;
        };
        directory = {
          truncation_symbol = "…/";
        };
      };
    };

    home.packages = with pkgs; [
      fd
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

    programs.exa = {
      enable = true;
      enableAliases = true;
    };

    programs.bat = {
      enable = true;
      config.theme = "Nord";
    };

    programs.fzf = {
      enable = true;
      fileWidgetCommand = "fd --type f --type d --type symlink";
      defaultCommand = "fd --type f";
      changeDirWidgetCommand = "fd --type d";
    };

    programs.htop.enable = true;
    programs.home-manager.enable = true;

    programs.zsh = {
      enable = true;
      enableAutosuggestions = true;
      enableSyntaxHighlighting = true;
      initExtra = ''
        source ${pkgs.myPkgs.zsh-forgit}/share/zsh-forgit/forgit.plugin.zsh

        export EDITOR="${cfg.editor}"
        export MANPAGER="sh -c 'col -bx | bat -l man -p'" # batman

        # term title
        export ZSH_THEME_TERM_TITLE_IDLE="%~"

        # ZSH COMPLETION CASE (IN)SENSITIVE
        zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

        # zsh-fzf-tab
        source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
        
        # https://github.com/Aloxaf/fzf-tab/tree/7e0eee64df6c7c81a57792674646b5feaf89f263#configure
        zstyle ':completion:*:git-checkout:*' sort false
        zstyle ':completion:*:descriptions' format '[%d]'
        zstyle ':fzf-tab:complete:cd:*' fzf-preview 'exa -1 --color=always $realpath'
        zstyle ':fzf-tab:*' switch-group ',' '.'
      '' + (if cfg.vi-mode.enable
      then ''
        source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
      ''
      else "");
      shellAliases = mkMerge [
        (mkIf true {
          cat = "${pkgs.bat}/bin/bat";
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
        ];
      };
    };
  };
}
