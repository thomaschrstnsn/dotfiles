{ pkgs, config, lib, ... }:
with lib; with builtins;

let
  cfg = config.tc.hyprland;

  gentle-down = pkgs.writeShellApplication {
    name = "gentle-down";
    text = readFile ./hypr/gentle_down.sh;
  };
  cursor.size = 64;
in
{
  options.tc.hyprland = with types; {
    enable = mkEnableOption "hyprland";
  };
  config = mkIf cfg.enable
    {
      fonts.fontconfig.enable = true;
      home.packages = with pkgs; [
        myPkgs.appleFonts.sf-pro
        bemoji # emoji picker
        clipse # clipboard history
        (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
        font-awesome
        gentle-down
        hyprpanel
        hyprshot
        jq # for scripts
        libnotify
        overskride # bluetooth
        pavucontrol
        pulseaudio
        python312Packages.gpustat # hyprpanel
        wl-clipboard
        wtype # dep for bemoji
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
          # based on https://github.com/MrVivekRajan/Hyprlock-Styles/blob/main/Style-3/hyprlock.conf
          general = {
            disable_loading_bar = false;
            no_fade_in = false;
          };

          background = [
            {
              path = "~/.wallpaper/wide/wallhaven-m3kggk_3840x2160.png";
              blur_passes = 3;
              contrast = 0.9;
              brightness = 0.8;
              vibrancy = 0.2;
              vibrancy_darkness = 0.0;
            }
          ];

          label = [
            # day month date
            {
              text = "cmd[update:1000] echo $(date +'%A, %B %d')";
              font_size = 25;
              color = "rgba(216, 222, 233, 0.70)";
              font_family = "SF Pro Display Bold";
              position = "0, 350";
              halign = "center";
              valign = "center";
            }
            # time
            {
              text = ''cmd[update:1000] echo "<span>$(date +"%H:%M")</span>"'';
              font_size = 120;
              color = "rgba(216, 222, 233, 0.70)";
              font_family = "SF Pro Display Bold";
              position = "0, 250";
              halign = "center";
              valign = "center";
            }
            # user
            {
              text = "    $USER";
              color = "rgba(216, 222, 233, 0.80)";
              outline_thickness = 2;
              dots_size = 0.2;
              dots_spacing = 0.2;
              dots_center = true;
              font_size = 18;
              font_family = "SF Pro Display Bold";
              position = "0, -130";
              halign = "center";
              valign = "center";
            }
          ];

          shape =
            {
              # USER-BOX
              size = "300, 60";
              color = "rgba(255, 255, 255, .1)";
              rounding = -1;
              border_size = 0;
              border_color = "rgba(253, 198, 135, 0)";
              rotate = 0;
              xray = false; # if true, make a "hole" in the background (rectangle of specified size, no rotation)
              position = "0, -130";
              halign = "center";
              valign = "center";
            };

          input-field = {
            size = "300, 60";
            outline_thickness = 2;
            dots_size = 0.2;
            dots_spacing = 0.2;
            dots_center = true;
            outer_color = "rgba(0, 0, 0, 0)";
            inner_color = "rgba(255, 255, 255, 0.1)";
            font_color = "rgb(200, 200, 200)";
            fade_on_empty = false;
            font_family = "SF Pro Display Bold";
            placeholder_text = ''🔒 <i><span foreground="##ffffff99">Enter Pass</span></i>'';
            hide_input = false;
            position = "0, -210";
            halign = "center";
            valign = "center";
          };
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
              timeout = 120;
              on-timeout = "hyprctl dispatch dpms off";
              on-resume = "hyprctl dispatch dpms on";
            }
            {
              timeout = 240;
              on-timeout = "systemctl suspend";
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

        extraConfig = ''
          bind = SUPER, q, exec, sleep 0.3 && hyprctl dispatch submap reset
          bind = SUPER, q, submap, kill
          submap = kill
          bind = SUPER, q, killactive
          submap = reset
        '';

        settings = {
          env = [
            "HYPRSHOT_DIR,~/Screenshots"
            "HYPRCURSOR_SIZE,${builtins.toString cursor.size}"
            "XCURSOR_SIZE,${builtins.toString cursor.size}"
          ];
          # debug.disable_logs = false;
          exec-once = [
            "hyprlock"
            "clipse -listen"
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

          windowrulev2 = [
            "float,class:(clipse)" # ensure you have a floating window class set if you want this behavior
            "size 622 652,class:(clipse)" # set the size of the window as necessary
          ];

          # https://wiki.hyprland.org/Configuring/Uncommon-tips--tricks/
          input = {
            kb_layout = "gb,dk";
            repeat_rate = 35;
            repeat_delay = 350;
            touchpad = {
              scroll_factor = 0.5;
              drag_lock = true;
            };
          };

          device = [
            {
              name = "thomas'-pegefelt";
              sensitivity = 0.4;
              natural_scroll = true;
            }
          ];

          decoration = {
            rounding = 16;

            # Change transparency of focused and unfocused windows
            active_opacity = 1.0;
            inactive_opacity = 1.0;

            drop_shadow = true;
            shadow_range = 4;
            shadow_render_power = 3;
            "col.shadow" = "rgba(1a1a1aee)";

            blur = {
              enabled = true;
              size = 3;
              passes = 1;
              vibrancy = 0.1696;
            };
          };

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
            disable_hyprland_logo = true;
          };
          binds = {
            workspace_center_on = true;
          };
          cursor = {
            default_monitor = "DP-2";
          };

          bezier = [
            "easeOutBack,0.34,1.56,0.64,1"
            "easeInBack,0.36,0,0.66,-0.56"
            "easeInCubic,0.32,0,0.67,0"
            "easeInOutCubic,0.65,0,0.35,1"
          ];
          animation = [
            "windowsIn,1,5,easeOutBack,popin"
            "windowsOut,1,5,easeInBack,popin"
            "fadeIn,0"
            "fadeOut,1,10,easeInCubic"
            "workspaces,1,4,easeInOutCubic,slide"
          ];

          "$hyper" = "SUPER+SHIFT+CTRL+ALT";
          bindm = [ "ALT, mouse:272, movewindow" ];

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
                "$hyper, f, fullscreen, 0"
                "CTRL+SUPER, q, exec, pidof hyprlock || hyprlock"
                "SHIFT+SUPER, 4, exec, hyprshot -m region"
                "SHIFT+SUPER, 3, exec, hyprshot -m window"
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
                "SUPER+SHIFT, C, exec, wezterm start --class clipse -e 'clipse'"
                # "ALT, comma, exec, <reserved for giphy picker>"
                "ALT, period, exec, bemoji -t"

                # toggle kb_layout
                "ALT, Space, exec, ${./hypr/toggle_kb_layout.sh} kanata"

                "SUPER, Tab, focuscurrentorlast"
              ]
              [
                ''$hyper, grave, exec, hyprctl reload'' # reload config, bring back monitors
                ''$hyper, 1, exec, hyprctl keyword monitor "DP-2, disable"'' # disable first monitor
                ''$hyper, 2, exec, hyprctl keyword monitor "HDMI-A-1, disable"'' # disable second monitor
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
