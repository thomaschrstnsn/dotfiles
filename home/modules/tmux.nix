{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.tmux;
in
{
  options.tc.tmux = {
    enable = mkEnableOption "tmux";
  };

  config = mkIf (cfg.enable) {
    programs.tmux = {
      enable = true;
      clock24 = true;
      baseIndex = 1;
      sensibleOnTop = true;
      terminal = "screen-256color";
      extraConfig = ''
        set -g mouse on
      '';
    };

    programs.zsh.initExtraBeforeCompInit = ''
      # starting shell from ssh and tmux is not running
      if [[ -n $SSH_CONNECTION && -z "$TMUX" ]]; then
        echo "autostarting tmux"
        ZSH_TMUX_AUTOSTART=true
        ZSH_TMUX_CONFIG=~/.config/tmux/tmux.conf
      fi
    '';

    programs.zsh.oh-my-zsh.plugins = [ "tmux" ];
  };
}
