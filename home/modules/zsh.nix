{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.zsh;
in
{
  options.tc.zsh = {
    enable = mkEnableOption "zsh with settings";

    skhd = mkOption {
      description = "Enable reload skhd alias";
      type = types.bool;
      default = false;
    };
    editor = mkOption {
      description = "Set $EDITOR (for cmdline git etc)";
      type = types.str;
      default = "code --wait";
    };
  };

  config = mkIf (cfg.enable) {
    home.packages = with pkgs; [
      fd
      tree
      wget
      zsh-powerlevel10k
    ];
    home.file.".p10k.zsh".source = ./zsh/p10k.zsh;

    programs.exa = {
      enable = true;
      enableAliases = true;
    };

    programs.bat = {
      enable = true;
      config.theme = "Visual Studio Dark+";
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

        # term title
        export ZSH_THEME_TERM_TITLE_IDLE="%~"

        # ZSH COMPLETION CASE (IN)SENSITIVE
        zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
      '';
      initExtraBeforeCompInit = ''
        source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
        source ~/.p10k.zsh
      '';
      shellAliases = mkMerge [
        (mkIf true {
          cat = "${pkgs.bat}/bin/bat";
          reload_zshrc = "source ~/.zshrc";
        })
        (mkIf (cfg.skhd) {
          # https://github.com/LnL7/nix-darwin/issues/333
          skhd-reload = "launchctl stop org.nixos.skhd && launchctl start org.nixos.skhd";
        })
      ];

      sessionVariables = {
        EDITOR = cfg.editor;
        MANPAGER = "sh -c 'col -bx | bat -l man -p'"; # batman
      };

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
