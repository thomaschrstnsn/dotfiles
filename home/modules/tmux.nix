{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.tmux;
  usercfg = config.tc.user;
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
        if [ ! -S ~/.ssh/ssh_auth_sock ] && [ -S "$SSH_AUTH_SOCK" ]; then
          echo "forwarding ssh-agent"
          ln -sf $SSH_AUTH_SOCK /tmp/ssh-agent-${usercfg.username}-tmux
        fi
        export SSH_AUTH_SOCK=/tmp/ssh-agent-${usercfg.username}-tmux
      fi
    '';

    programs.zsh.oh-my-zsh.plugins = [ "tmux" ];
  };
}
