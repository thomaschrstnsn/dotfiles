{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.sway;
  mod = "Mod4";
  lockCmd = "'swaylock -f -c 445566'";
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
      pavucontrol
      pulseaudio
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
        keybindings = lib.mkOptionDefault {
          XF86MonBrightnessUp = "exec light -A 10";
          XF86MonBrightnessDown = "exec light -U 10";
          # Control volume
          XF86AudioRaiseVolume = "exec pactl set-sink-volume @DEFAULT_SINK@ +10%";
          XF86AudioLowerVolume = "exec pactl set-sink-volume @DEFAULT_SINK@ -10%";
          XF86AudioMute = "exec pactl set-sink-mute @DEFAULT_SINK@ toggle";
          XF86AudioMicMute = "exec pactl set-source-mute @DEFAULT_SOURCE@ toggle";
          # "Mod4+l" = "exec ${lockCmd}";
        };
        startup = [
          {
            command = ''
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
  };
}
