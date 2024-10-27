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
  }."${cfg.theme}";
  disabledBg = "#d20f39";
in
{
  options.tc.tmux = with types; {
    enable = mkEnableOption "tmux";
    theme = mkOption {
      type = enum [ "catppuccin" "dracula" "rose-pine" ];
      default = "catppuccin";
      description = "theme for tmux";
    };
    remote = mkEnableOption "is remote machine";
    cliptool = mkOption {
      type = str;
      default = "auto";
      description = "override the extrakto_clip_tool";
    };
    session-tool = mkOption {
      type = nullOr (enum [ "tmux-sessionizer" "sesh" ]);
      default = "sesh";
      description = "session tool inside tmux";
    };
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

      '' + concatStringsSep "\n"
        ((if (cfg.session-tool == "tmux-sessionizer") then
          [
            ''bind C-o display-popup -E "tms"''
            ''bind C-j display-popup -E "tms switch"''
          ]
        else [ ]) ++
        (if (cfg.session-tool == "sesh") then [
          ''
                              bind-key "C-k" run-shell "sesh connect \"$(
                                  sesh list | fzf-tmux -p 55%,60% \
                                    --no-sort --border-label ' sesh ' --prompt '⚡  ' \
                                      --header '  ^a all ^t tmux ^s src/ ^g configs ^x zoxide ^d tmux kill ^f find' \
                                    --bind 'tab:down,btab:up' \
                                    --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list)' \
                                    --bind 'ctrl-s:change-prompt(👩‍💻  )+reload(fd -d 1 -t d . ~/src)' \
                                    --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t)' \
                                    --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -c)' \
                                    --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z)' \
                                    --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~)' \
                                    --bind 'ctrl-d:execute(tmux kill-session -t {})+change-prompt(⚡  )+reload(sesh list)'
                              )\""

                              bind-key "C-j" display-popup -E -w 40% "sesh connect \"$(
            	                sesh list -i | gum filter --limit 1 --no-sort --placeholder 'Pick a sesh' --height 50 --prompt='⚡'
                              )\""
          ''
        ] else [ ])
        );
      plugins = with pkgs.tmuxPlugins; [
        vim-tmux-navigator
        extrakto # https://github.com/laktak/extrakto
        sensible
        (mkIf (cfg.theme == "dracula") {
          plugin = dracula;
          extraConfig = ''
            set -g @dracula-plugins "ssh-session time"
            set -g @dracula-show-powerline true
            set -g @dracula-show-battery false
            set -g @dracula-show-left-icon session
            set -g @dracula-time-format "%Y-%m-%d %H:%M"
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
                set -g @catppuccin_date_time "W%W %Y-%m-%d %H:%M"
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
                set -g @rose_pine_date_time 'W%W %Y-%m-%d %H:%M'
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
      ];
    };

    home.packages = with pkgs; builtins.concatLists [
      (if (cfg.session-tool == "tmux-sessionizer") then [ tmux-sessionizer ] else [ ])
      (if (cfg.session-tool == "sesh") then [ sesh gum ] else [ ])
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
