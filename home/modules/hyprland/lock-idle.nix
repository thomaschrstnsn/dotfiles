# Lockscreen (hyprlock) and idle handling (hypridle).
{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.hyprland;

  inherit (import ./commands.nix { inherit pkgs cfg; }) lockCmd useHyprlock;
in
{
  config = mkIf cfg.enable {
    programs.hyprlock = mkIf useHyprlock {
      enable = true;
      settings = {
        # based on https://github.com/MrVivekRajan/Hyprlock-Styles/blob/main/Style-3/hyprlock.conf
        general = {
          disable_loading_bar = false;
          no_fade_in = false;
        };

        background = [
          {
            path = "~/Pictures/WallDiscovery/wallhaven.cc/lqkr2q.jpeg";
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
            text = "    $USER";
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
          lock_cmd = lockCmd;
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = "hyprctl dispatch 'hl.dsp.dpms({ action = \"on\" })'";
          ignore_dbus_inhibit = false;
        };

        listener = [
          {
            timeout = cfg.idle.lock;
            on-timeout = "loginctl lock-session";
          }
          {
            timeout = cfg.idle.dpmsOff;
            on-timeout = "hyprctl dispatch 'hl.dsp.dpms({ action = \"off\" })'";
            on-resume = "hyprctl dispatch 'hl.dsp.dpms({ action = \"on\" })'";
          }
          {
            timeout = cfg.idle.suspend;
            on-timeout = "systemctl suspend";
          }
        ];
      };
    };
  };
}
