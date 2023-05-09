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
          command = "${pkgs.sway}/bin/swaybar";
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
  };
}
