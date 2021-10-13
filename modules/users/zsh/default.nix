{ pkgs, config, lib, ... }:
with lib;

let 
  cfg = config.tc.zsh;
in {
  options.tc.zsh = {
    enable = mkOption {
      description = "Enable zsh with settings";
      type = types.bool;
      default = true;
    };
    enableSyntaxHighlighting = mkOption {
      description = "Fix until >21.05 version homemanager is used (has enableSyntaxHighlighting builtin)";
      type = types.bool;
      default = true;
    };
  };

  config = mkIf (cfg.enable) (
    let 
      x = "y";
    in {
    home.packages = with pkgs; [
      tree
      wget
      zsh-powerlevel10k
    ];
    home.file.".p10k.zsh".source = ./p10k.zsh;

    programs.zsh = {
      enable = true;
      enableAutosuggestions = true;
      # enableSyntaxHighlighting = true;
      initExtra = ''
        export IHP_EDITOR="code --goto"
      '';
      initExtraBeforeCompInit = ''
        source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
        source ~/.p10k.zsh
        # starting shell from ssh and tmux is not running
        if [[ -n $SSH_CONNECTION && -z "$TMUX" ]]; then
          echo "autostarting tmux"
          ZSH_TMUX_AUTOSTART=true
        fi
        ${optionalString cfg.enableSyntaxHighlighting
          "source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
        }
      '';
      completionInit = ''
        # ZSH COMPLETION CASE (IN)SENSITIVE
        zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
      '';
      shellAliases = {
        # bat
        cat = "${pkgs.bat}/bin/bat";
      };
    };
  });
}
