{ pkgs, config, lib, ... }:
with lib;

let 
  cfg = config.tc.tmux;
in {
  options.tc.tmux = {
    enable = mkOption {
      description = "Enable tmux with zsh";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable) {
    home.packages = with pkgs; [
      tmux
    ];

    programs.zsh.initExtraBeforeCompInit = ''
      # starting shell from ssh and tmux is not running
      if [[ -n $SSH_CONNECTION && -z "$TMUX" ]]; then
        echo "autostarting tmux"
        ZSH_TMUX_AUTOSTART=true
      fi
    '';

    programs.zsh.oh-my-zsh.plugins = [ "tmux" ];
  };
}