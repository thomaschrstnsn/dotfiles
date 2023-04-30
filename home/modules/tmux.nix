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

  config = mkIf cfg.enable {
    programs.tmux = {
      enable = true;
      clock24 = true;
      baseIndex = 1;
      terminal = "xterm-256color";
      keyMode = "vi";
      mouse = true;
      shortcut = "Space";
      extraConfig = ''
        set-option -sa terminal-overrides ",xterm*:Tc"
        set-option -g status-position top

        unbind r
        bind r source ~/.config/tmux/tmux.conf
        
        # Vim style pane selection
        bind h select-pane -L
        bind j select-pane -D 
        bind k select-pane -U
        bind l select-pane -R

        bind '"' split-window -v -c "#{pane_current_path}"
        bind % split-window -h -c "#{pane_current_path}"
      '';
      plugins = with pkgs.tmuxPlugins; [
        vim-tmux-navigator
        sensible
        {
          plugin = mkTmuxPlugin {
            pluginName = "catppuccin-tmux";
            version = "26617ca";
            rtpFilePath = "catppuccin.tmux";
            src = pkgs.fetchFromGitHub {
              owner = "dreamsofcode-io";
              repo = "catppuccin-tmux";
              rev = "b4e0715356f820fc72ea8e8baf34f0f60e891718";
              sha256 = "sha256-FJHM6LJkiAwxaLd5pnAoF3a7AE1ZqHWoCpUJE0ncCA8=";
            };
          };
          extraConfig = ''
            set -g @catppuccin_date_time "%Y-%m-%d %H:%M"
            set -g @catppuccin_host "on"
          '';
        }
      ];
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
      export ZSH_TMUX_CONFIG=~/.config/tmux/tmux.conf
    '';

    programs.zsh.oh-my-zsh.plugins = [ "tmux" ];
  };
}
