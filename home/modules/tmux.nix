{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.tmux;
  usercfg = config.tc.user;
  remoteConfigFile = "tmux.remote.conf";
  mochaBg = "#1e1e2e";
  disabledBg = "#d20f39";
in
{
  options.tc.tmux = {
    enable = mkEnableOption "tmux";
  };

  config = mkIf cfg.enable {

    xdg.configFile."tmux/${remoteConfigFile}".text = ''
      # set-option -g status-position bottom
    '';
    programs.tmux = {
      enable = true;
      clock24 = true;
      baseIndex = 1;
      keyMode = "vi";
      mouse = true;
      shortcut = "Space";
      extraConfig = ''
        # set-option -sa terminal-overrides ",xterm*:Tc"
        set-option -ga terminal-overrides ",xterm-256color:Tc,screen-256color:Tc,tmux-256color:Tc"
        set-option -g status-position top
        set-option -g set-clipboard on
        set-option -g detach-on-destroy off

        # https://github.com/samoshkin/tmux-config/blob/af2efd9561f41f30c51c9deeeab9451308c4086b/tmux/yank.sh
        yank="${tmux/yank.sh}"

        # Remap keys which perform copy to pipe copied text to OS clipboard
        bind -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel "$yank"
        bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "$yank"
        bind -T copy-mode-vi Y send-keys -X copy-pipe-and-cancel "$yank; tmux paste-buffer"
        bind -T copy-mode-vi C-j send-keys -X copy-pipe-and-cancel "$yank"
        bind-key -T copy-mode-vi D send-keys -X copy-end-of-line \;\
            run "tmux save-buffer - | $yank"
        bind-key -T copy-mode-vi A send-keys -X append-selection-and-cancel \;\
            run "tmux save-buffer - | $yank"

        set -g @thumbs-command 'echo {} | $yank && tmux display-message \"Copied {}\"'
        set -g @extrakto_clip_tool '$yank'

        unbind r
        bind r 'source ~/.config/tmux/tmux.conf; display "reloaded config"'
        
        # Vim style pane selection
        bind h select-pane -L
        bind j select-pane -D 
        bind k select-pane -U
        bind l select-pane -R

        bind C-o display-popup -E "tms"
        bind C-j display-popup -E "tms switch"

        bind '"' split-window -v -c "#{pane_current_path}"
        bind % split-window -h -c "#{pane_current_path}"

        # remote / nested session support. 
        # inspired by: https://github.com/samoshkin/tmux-config/blob/95efd543846a27cd2127496b74fd4f4da94f4a31/tmux/tmux.conf

        if-shell 'test -n "$SSH_CLIENT"' 'source-file ~/.config/tmux/${remoteConfigFile}'

        bind -T root F12 \
          set prefix None \;\
          set key-table off \;\
          if -F '#{pane_in_mode}' 'send-keys -X cancel' \;\
          set status-bg '${disabledBg}' \;\
          refresh-client -S \;\

        bind -T off F12 \
          set -u prefix \;\
          set -u key-table \;\
          set -u status-style \;\
          set status-bg '${mochaBg}' \;\
          refresh-client -S
      '';
      plugins = with pkgs.tmuxPlugins; [
        vim-tmux-navigator
        extrakto # https://github.com/laktak/extrakto
        tmux-thumbs # https://github.com/fcsonline/tmux-thumbs
        sensible
        {
          plugin = mkTmuxPlugin {
            pluginName = "catppuccin-tmux";
            version = "e7b50832f9bc59b0b5ef5316ba2cd6f61e4e22fc";
            rtpFilePath = "catppuccin.tmux";
            src = pkgs.fetchFromGitHub {
              owner = "dreamsofcode-io";
              repo = "catppuccin-tmux";
              rev = "e7b50832f9bc59b0b5ef5316ba2cd6f61e4e22fc";
              sha256 = "sha256-9ZfUqEKEexSh06QyR5C+tYd4tNfBi3PsA+STzUv4+/s";
            };
          };
          extraConfig = ''
            set -g @catppuccin_date_time "%Y-%m-%d %H:%M"
            set -g @catppuccin_host "on"
            set -g @catppuccin_datetime_icon "󰔠"
          '';
        }
      ];
    };

    home.packages = with pkgs; [
      tmux-sessionizer
    ];

    programs.zsh.initExtraBeforeCompInit = ''
      export ZSH_TMUX_AUTOQUIT=false
      export ZSH_TMUX_AUTOSTART=true
      export ZSH_TMUX_UNICODE=true
      export ZSH_TMUX_CONFIG=~/.config/tmux/tmux.conf

      # starting shell from ssh and tmux is not running
      if [[ -n $SSH_CONNECTION && -z "$TMUX" ]]; then
        echo "autostarting tmux"
        export ZSH_TMUX_AUTOQUIT=true
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
