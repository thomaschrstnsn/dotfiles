{ pkgs, config, lib, ... }:
with lib; with builtins;

let
  cfg = config.tc.hyprland;
in
{
  options.tc.hyprland = with types; {
    enable = mkEnableOption "hyprland";
  };
  config = mkIf cfg.enable
    {
      fonts.fontconfig.enable = true;
      home.packages = with pkgs; [
        font-awesome
        (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
        hyprpanel
        python312Packages.gpustat # hyprpanel
        jq # for scripts
        libnotify
        pavucontrol
        pulseaudio
        wl-clipboard
      ];

      dconf = {
        enable = true;
        settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
      };

      programs.wofi = {
        enable = true;
        style = readFile ./wofi/style.css;
      };

      programs.hyprlock = {
        enable = true;
        settings = {
          general = {
            disable_loading_bar = true;
            hide_cursor = true;
            no_fade_in = false;
            grace = 3;
          };

          background = [
            {
              path = "~/.wallpaper/wide/wallhaven-m3kggk_3840x2160.png";
              blur_passes = 2;
              contrast = 1;
              brightness = 0.5;
              vibrancy = 0.2;
              vibrancy_darkness = 0.2;
            }
          ];

          label = {
            text = "cmd[update:1000] echo $(date '+%-I:%M')";
            font_size = 95;
            font_family = "JetBrains Mono";
            position = "0, 200";
            halign = "center";
            valign = "center";
          };

          input-field = [
            {
              size = "250, 60";
              position = "0, -200";
              halign = "center";
              valign = "center";
              monitor = "";
              dots_center = true;
              dots_size = 0.2;
              dots_space = 0.35;
              fade_on_empty = false;
              rounding = -1;
              font_color = "rgb(202, 211, 245)";
              inner_color = "rgb(91, 96, 120)";
              outer_color = "rgb(24, 25, 38)";
              outline_thickness = 2;
              placeholder_text = ''<i><span foreground="##cdd6f4">Input Password...</span></i>'';
              shadow_passes = 2;
            }
          ];
        };
      };

      services.hypridle = {
        enable = true;
        settings = {
          general = {
            lock_cmd = "pidof hyprlock || hyprlock";
            before_sleep_cmd = "loginctl lock-session";
            after_sleep_cmd = "hyprctl dispatch dpms on";
            ignore_dbus_inhibit = false;
          };

          listener = [
            {
              timeout = 120;
              on-timeout = "hyprlock";
            }
            {
              timeout = 300;
              on-timeout = "hyprctl dispatch dpms off";
              on-resume = "hyprctl dispatch dpms on";
            }
          ];
        };
      };

      services.hyprpaper = {
        enable = true;
        settings = {
          # https://wallhaven.cc/
          # ├── portrait
          # │   ├── wallhaven-9dp961_2160x3840.png
          # │   ├── wallhaven-m3k8jk_1311x1900.png
          # │   └── wallhaven-yxrgjx_1440x2560.png
          # └── wide
          #     ├── wallhaven-m3kggk_3840x2160.png
          #     ├── wallhaven-rrl8rw_3840x2160.png
          #     └── wallhaven-yxp6zl_3840x2160.png
          preload = [ "~/.wallpaper/wide/wallhaven-m3kggk_3840x2160.png" "~/.wallpaper/portrait/wallhaven-9dp961_2160x3840.png" ];
          wallpaper = [
            "DP-2,~/.wallpaper/wide/wallhaven-m3kggk_3840x2160.png"
            "HDMI-A-1,~/.wallpaper/portrait/wallhaven-9dp961_2160x3840.png"
          ];

        };
      };

      wayland.windowManager.hyprland = {
        enable = true;

        settings = {
          exec-once = [
            "${pkgs.hyprpanel}/bin/hyprpanel"
            "[workspace name:t silent] wezterm"
            "[workspace name:b silent] brave"
            "[workspace name:u silent] logseq"
            "[workspace name:p silent] todoist-electron"
            "[workspace name:p silent] 1password"
            "[workspace name:c silent] morgen"
            "[workspace name:m silent] spotify"
          ];

          workspace = [
            "name:t, monitor:DP-2, default:true, persistent:true"
            "name:u, monitor:HDMI-A-1, default:true, persistent:true"
            "name:b, monitor:DP-2, persistent:true"
            "name:p, monitor:DP-2, persistent:true"
            "name:c, monitor:DP-2, persistent:true"
            "name:m, monitor:DP-2, persistent:true"
          ];

          # https://wiki.hyprland.org/Configuring/Uncommon-tips--tricks/
          input = {
            kb_layout = "gb,dk";
            repeat_rate = 35;
            repeat_delay = 200;
          };

          decoration.rounding = 5;
          general = {
            border_size = 3;
            resize_on_border = true;
            gaps_in = 5;
            gaps_out = 5;
          };
          cursor.inactive_timeout = 3;

          misc = {
            key_press_enables_dpms = true;
            vrr = 2;
          };
          binds = {
            workspace_center_on = true;
          };
          cursor = {
            default_monitor = "DP-2";
          };

          "$hyper" = "SUPER+SHIFT+CTRL+ALT";
          bind =
            let
              workspaceChars = stringToCharacters ("123456789" + "qwertyuiop" + "zxcvbnm");
              repeatBind = bind: keys: (map (k: (replaceStrings [ "$KEY" ] [ "${k}" ] bind)) keys);
              appShortcuts = mod: keyToWindow: mapAttrsToList (key: window: "${mod}, ${key}, focuswindow, ${window}") keyToWindow;
            in
            concatLists [
              [
                "SUPER, Return, exec, wezterm"
                "SUPER, Space, exec, pgrep wofi || wofi --show run"
                "SUPER, q, killactive"
                "$hyper, f, fullscreen, 0"
                "CTRL+SUPER, q, exec, pidof hyprlock || hyprlock"
              ]
              # mediakeys
              [

                ", XF86AudioRaiseVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ +10%"
                ", XF86AudioLowerVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ -10%"
                ", XF86AudioMute, exec, pactl set-sink-mute @DEFAULT_SINK@ toggle"
                ", XF86AudioMicMute, exec, pactl set-source-mute @DEFAULT_SOURCE@ toggle"
              ]
              (repeatBind "ALT, $KEY, workspace, name:$KEY" workspaceChars)
              (repeatBind "SHIFT + ALT, $KEY, movetoworkspace, name:$KEY" workspaceChars)
              (repeatBind "CTRL + ALT, $KEY, movetoworkspacesilent, name:$KEY" workspaceChars)
              [
                "$hyper, h, movefocus, l"
                "$hyper, j, movefocus, d"
                "$hyper, k, movefocus, u"
                "$hyper, l, movefocus, r"

                "$hyper, q, movecurrentworkspacetomonitor, l"
                "$hyper, w, movecurrentworkspacetomonitor, r"
              ]
              (appShortcuts "$hyper" {
                t = "org.wezfurlong.wezterm";
                b = "Brave-browser";
                u = "Logseq";
                p = "Todoist";
              })
              [
                # copy/paste using super
                "SUPER, C, exec, ${./hypr/copy_unless_wezterm.sh}"
                "SUPER, V, exec, ${./hypr/paste_unless_wezterm.sh}"
                "SUPER, Z, exec, ${./hypr/undo_unless_wezterm.sh}"

                # toggle kb_layout
                "ALT, Space, exec, ${./hypr/toggle_kb_layout.sh} kanata"

                "SUPER, Tab, focuscurrentorlast"
              ]
            ];

          # https://wiki.hyprland.org/Configuring/Monitors/#rotating
          monitor = [
            "DP-2, 2560x1440@165, 0x0, 1"
            "HDMI-A-1, 2560x1440@60, 2560x-100, 1, transform, 1"
            ", preferred, auto, 1"
          ];
        };
      };
    };
}
