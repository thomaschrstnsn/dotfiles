{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.sway;
  mod = "Mod4";
in
{
  options.tc.sway = {
    enable = mkEnableOption "sway";
  };

  config = mkIf cfg.enable {
    fonts.fontconfig.enable = true;
    home.packages = with pkgs; [
      wl-clipboard
      wofi
      font-awesome
      swaylock
      swayidle
    ];
    wayland.windowManager.sway = {
      enable = true;
      # systemdIntegration = true;
      wrapperFeatures.gtk = true;

      extraSessionCommands = ''
        export SDL_VIDEODRIVER=wayland
        export QT_QPA_PLATFORM=wayland
        export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
        export __JAVA_AWT_WM_NONREPARENTING=1
        export MOZ_ENABLE_WAYLAND=1
      '';

      # examples:
      # - https://git.sr.ht/~jshholland/nixos-configs/tree/master/home/sway.nix

      config = {
        modifier = mod;
        workspaceAutoBackAndForth = true;
        terminal = "wezterm";
        menu = "wofi --show run";
        input = {
          "type:keyboard" = {
            xkb_layout = "gb";
            xkb_options = "caps:escape";
          };
          "type:touchpad" = {
            tap = "enabled";
            natural_scroll = "enabled";
            scroll_factor = "0.3";
          };
        };
        bars = [{
          command = "waybar";
          position = "top";
        }];
        startup = [
          {
            command =
              let lockCmd = "'swaylock -f -c 445566'";
              in
              ''
                swayidle -w \
                  timeout 300 ${lockCmd} \
                  timeout 600 'swaymsg "output * dpms off"' \
                  resume 'swaymsg "output * dpms on"' \
                  before-sleep ${lockCmd}
              '';
          }
        ];
      };
      extraConfig = ''
        bindsym ${mod}+t [app_id="org.wezfurlong.wezterm"] focus
        # bindsym ${mod}+b [class="Brave-browser"] focus
        for_window [app_id="org.wezfurlong.wezterm"] border none
      '';
      swaynag.enable = true;
    };
    programs.waybar = {
      enable = true;
      settings =
        let
          battery = { name }: {
            bat = name;
            states = {
              warning = 30;
              critical = 15;
            };
            format = "{capacity}% {icon}";
            format-charging = "{capacity}% ";
            format-plugged = "{capacity}% ";
            format-alt = "{time} {icon}";
            format-icons = [ "" "" "" "" "" ];
          };
          media = { number }: {
            format = "{icon} {}";
            return-type = "json";
            max-length = 55;
            format-icons = {
              Playing = "";
              Paused = "";
            };
            exec = "mediaplayer ${toString number}";
            exec-if = "[ $(playerctl -l 2>/dev/null | wc -l) -ge ${toString (number + 1)} ]";
            interval = 1;
            on-click = "play-pause ${toString number}";
          };
          audioSupport = true;
        in
        [{
          height = 40;
          modules-left = [ "sway/workspaces" "sway/mode" (mkIf audioSupport "custom/media#0") (mkIf audioSupport "custom/media#1") ];
          modules-center = [ ];
          modules-right = [ "tray" (mkIf audioSupport "pulseaudio") "network" "memory" "cpu" "backlight" "battery#bat0" "battery#bat1" "clock" "custom/power" ];
          modules = {
            "sway/workspaces" = {
              all-outputs = true;
              format = "{icon}";
              format-icons = {
                "1" = "";
                "2" = "";
                "3" = "";
                "4" = "";
                "5" = "";
                "6" = "";
                "7" = "";
                "9" = "";
                "10" = "";
                focused = "";
                urgent = "";
                default = "";
              };
            };
            tray = {
              spacing = 10;
            };
            clock = {
              tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
              format-alt = "{:%A, %d %b}";
            };
            cpu = {
              format = "{usage}% ";
            };
            memory = {
              format = "{}% ";
            };
            backlight = {
              format = "{icon}";
              format-alt = "{percent}% {icon}";
              format-alt-click = "click-right";
              format-icons = [ "○" "◐" "●" ];
              on-scroll-down = "light -U 10";
              on-scroll-up = "light -A 10";
            };
            "battery#bat0" = battery { name = "BAT0"; };
            "battery#bat1" = battery { name = "BAT1"; };
            network = {
              format-wifi = "{essid} ({signalStrength}%) ";
              format-ethernet = "Ethernet ";
              format-linked = "Ethernet (No IP) ";
              format-disconnected = "Disconnected ";
              format-alt = "{bandwidthDownBits}/{bandwidthUpBits}";
              on-click-middle = "nm-connection-editor";
            };
            pulseaudio = mkIf audioSupport {
              scroll-step = 1;
              format = "{volume}% {icon} {format_source}";
              format-bluetooth = "{volume}% {icon} {format_source}";
              format-bluetooth-muted = " {icon} {format_source}";
              format-muted = " {format_source}";
              format-source = "{volume}% ";
              format-source-muted = "";
              format-icons = {
                headphone = "";
                hands-free = "";
                headset = "";
                phone = "";
                portable = "";
                car = "";
                default = [ "" "" "" ];
              };
              on-click = "pavucontrol";
            };
            "custom/media#0" = mkIf audioSupport (media { number = 0; });
            "custom/media#1" = mkIf audioSupport (media { number = 1; });
            "custom/power" = {
              format = "";
              on-click = "nwgbar -o 0.2";
              escape = true;
              tooltip = false;
            };
          };
        }];
      style = builtins.readFile ./waybar/style.css;
    };
  };
}
