{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.tmux;
  usercfg = config.tc.user;
  remoteConfigFile = "tmux.remote.conf";
  enabledBg = {
    dracula = "#44475a";
    catppuccin = "#1e1e2e";
    rose-pine = "#191724";
    powerkit = "#2a2b3d";
  }."${cfg.theme}";
  defaultDisabled = "#d20f39";
  disabledBg = {
    dracula = defaultDisabled;
    catppucin = defaultDisabled;
    rose-pine = defaultDisabled;
    powerkit = "#ff6b85";
  }."${cfg.theme}";
in
{
  options.tc.tmux = with types; {
    enable = mkEnableOption "tmux";
    disableAutoStarting = mkEnableOption "no autostart";
    theme = mkOption {
      type = enum [ "catppuccin" "dracula" "rose-pine" "powerkit" ];
      default = "catppuccin";
      description = "theme for tmux";
    };
    remote = mkEnableOption "is remote machine";
    cliptool = mkOption {
      type = str;
      default = "auto";
      description = "override the extrakto_clip_tool";
    };
    aiAgent.enable = mkEnableOption "tmux ai agent integration";
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
        # https://github.com/wez/wezterm/discussions/4680
        set -g default-terminal "tmux-256color"
        set -ag terminal-overrides ",xterm-256color:RGB"

        # pass through shift+enter and ctrl+enter
        bind -n S-Enter send-keys Escape "[13;2u"
        bind -n C-Enter send-keys Escape "[13;5u"

        # image.nvim
        set -gq allow-passthrough on
        set -g visual-activity off

        # undercurls: https://github.com/folke/tokyonight.nvim#fix-undercurls-in-tmux
        set -as terminal-overrides ',*:Smulx=\E[4::%p1%dm'  # undercurl support
        set -as terminal-overrides ',*:Setulc=\E[58::2::%p1%{65536}%/%d::%p1%{256}%/%{255}%&%d::%p1%{255}%&%d%;m'  # underscore colours - needs tmux-3.0

        set-option -g status-position top
        set-option -g set-clipboard on
        set-option -g detach-on-destroy off

        bind-key x kill-pane # skip "kill-pane 1? (y/n)" prompt

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

        set -g @extrakto_clip_tool_run tmux_osc52
        set -g @extrakto_clip_tool ${cfg.cliptool}

        unbind r
        bind r 'source ~/.config/tmux/tmux.conf; display "reloaded config"'

        # Vim style pane selection
        bind h select-pane -L
        bind j select-pane -D
        bind k select-pane -U
        bind l select-pane -R

        bind m select-pane -m
        bind M select-pane -M
        bind < join-pane

        bind Space last-window
        bind C-Space last-window

        bind-key -r -T prefix       S-Up              resize-pane -U 5
        bind-key -r -T prefix       S-Down            resize-pane -D 5
        bind-key -r -T prefix       S-Left            resize-pane -L 5
        bind-key -r -T prefix       S-Right           resize-pane -R 5
        bind-key -r -T prefix       Up                resize-pane -U
        bind-key -r -T prefix       Down              resize-pane -D
        bind-key -r -T prefix       Left              resize-pane -L
        bind-key -r -T prefix       Right             resize-pane -R

        bind C-v select-layout main-vertical
        bind C-h select-layout main-horizontal

        bind '"' split-window -v -c "#{pane_current_path}"
        bind % split-window -h -c "#{pane_current_path}"

        ${if cfg.aiAgent.enable then ''
          # AI Agent integration
          bind-key a run-shell ${tmux/agent-toggle.sh}
          '' else ""}

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
          set status-bg '${enabledBg}' \;\
          refresh-client -S

        # toggle between two sessions
        bind -T prefix \\ switch-client -l

        # default-command was set to 'reattach-to-user-namespace -l /bin/sh' for some unknown reason
        set -g default-command ""

        bind-key "C-k" display-popup -E -w 40% "sesh connect \"$(
          sesh list -i | gum filter --limit 1 --no-sort --placeholder 'Pick a sesh' --height 50 --prompt='⚡'
          )\""
      '';
      plugins = with pkgs.tmuxPlugins; [
        vim-tmux-navigator
        extrakto # https://github.com/laktak/extrakto
        sensible
        {
          plugin = fuzzback; # https://github.com/roosta/tmux-fuzzback
          extraConfig = ''
            set -g @fuzzback-bind s
            set -g @fuzzback-popup 1
            set -g @fuzzback-popup-size '100%'
            set -g @fuzzback-hide-preview 1
          '';
          # TODO: Look into fzf binds: https://github.com/roosta/tmux-fuzzback?tab=readme-ov-file#finder-bind
          # e.g. copy content, paste into new nvim instance
        }
        (mkIf (cfg.theme == "dracula") {
          plugin = dracula;
          extraConfig = ''
            set -g @dracula-plugins "ssh-session time"
            set -g @dracula-show-powerline true
            set -g @dracula-show-battery false
            set -g @dracula-show-left-icon session
            set -g @dracula-time-format "W%V %Y-%m-%d %H:%M"
          '';
        })
        (mkIf (cfg.theme == "catppuccin")
          (
            let
              modules_right = if cfg.remote then "application session directory user host date_time" else "application session directory date_time";
            in
            {
              plugin = catppuccin;
              extraConfig = ''
                set -g @catppuccin_window_default_text "#W"
                set -g @catppuccin_window_status_enable "yes"
                set -g @catppuccin_window_status_icon_enable "yes"
                set -g @catppuccin_status_modules_right "${modules_right}"
                set -g @catppuccin_date_time "W%V %Y-%m-%d %H:%M"
              '';
            }
          ))
        (mkIf (cfg.theme == "rose-pine")
          (
            let
              remote_lines =
                if cfg.remote then ''
                  set -g @rose_pine_host 'on'
                  set -g @rose_pine_user 'on'
                ''
                else "";
            in
            {
              plugin = rose-pine;
              extraConfig = ''
                set -g @rose_pine_variant 'main'
                set -g @rose_pine_date_time 'W%V %Y-%m-%d %H:%M'
                set -g @rose_pine_date 'on'
                set -g @rose_pine_directory 'on' # Turn on the current folder component in the status bar
                set -g @rose_pine_disable_active_window_menu 'on' # Disables the menu that shows the active window on the left
                set -g @rose_pine_default_window_behavior 'on' # Forces tmux default window list behaviour
                set -g @rose_pine_show_current_program 'on' # Forces tmux to show the current running program as window name
                set -g @rose_pine_show_pane_directory 'on' # Forces tmux to show the current directory as window name

                ${remote_lines}
              '';
            }
          ))
        (mkIf (cfg.theme == "powerkit")
          {
            plugin = mkTmuxPlugin {
              pluginName = "powerkit";
              version = "v3.8.0";
              rtpFilePath = "tmux-powerkit.tmux";
              src = pkgs.fetchFromGitHub {
                owner = "fabioluciano";
                repo = "tmux-powerkit";
                rev = "9d5bfdaabf2a03e05d8ae11f1065f694d15df0d5";
                hash = "sha256-QhCUQDmt+Ur6KakrycJ4uvnIZzTHGkG/f01vslFxR5w";
              };
              meta = {
                homepage = "https://github.com/fabioluciano/tmux-powerkit/";
                description = "A powerful, modular tmux status bar framework with 33+ built-in plugins for displaying system information, development tools, security monitoring, and media status. Ships with beautiful themes including Tokyo Night and Kiribyte.";
                license = lib.licenses.mit;
              };
            };
            extraConfig = ''
              # Theme selection
              set -g @powerkit_theme 'kiribyte'

              # Auto-detect OS icon
              set -g @powerkit_session_icon 'auto'

              # Enable plugins
              set -g @powerkit_plugins 'battery,cpu,memory,network,ping,weather,datetime'

              set -g @powerkit_plugin_datetime_format 'iso'
              set -g @powerkit_plugin_datetime_show_week 'true'

              set -g @powerkit_plugin_weather_location 'Silkeborg'

            '';

          }
        )
      ];
    };

    programs.zsh.initContent = lib.mkOrder 550 (if cfg.disableAutoStarting then "" else ''
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
    '');

    programs.fish = {
      interactiveShellInit = lib.mkOrder 5000 (if cfg.disableAutoStarting then "" else ''
        set fish_tmux_autoquit false
        set fish_tmux_autostart_once true
        set fish_tmux_autoconnect false

        if test -n "$SSH_CONNECTION"; and test -z "$TMUX";
          echo "fish: autostarting tmux"
          set fish_tmux_autoquit true

          # ssh agent forwarding
          set fish_tmux_ssh_auth_sock /tmp/ssh-agent-${usercfg.username}-tmux
          if test -S $SSH_AUTH_SOCK;
            echo "fish: forwarding ssh agent"
            ln -sf $SSH_AUTH_SOCK $fish_tmux_ssh_auth_sock
          end
          set -gx SSH_AUTH_SOCK $fish_tmux_ssh_auth_sock
        end
        set fish_tmux_autostart true
      '');
      plugins = [
        {
          name = "tmux";
          src = pkgs.fetchFromGitHub {
            owner = "budimanjojo";
            repo = "tmux.fish";
            rev = "db0030b7f4f78af4053dc5c032c7512406961ea5";
            sha256 = "sha256-rRibn+FN8VNTSC1HmV05DXEa6+3uOHNx03tprkcjjs8";
          };
        }
      ];


    };

    programs.zsh.oh-my-zsh.plugins = [ "tmux" ];
  };
}
