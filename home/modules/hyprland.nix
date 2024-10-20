{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.hyprland;
  startupScript = pkgs.pkgs.writeShellScriptBin "start" ''
    ${pkgs.waybar}/bin/waybar &

    # wezterm &
    kitty &
  '';
in
{
  options.tc.hyprland = with types; {
    enable = mkEnableOption "hyprland";
  };
  config = mkIf cfg.enable
    {
      fonts.fontconfig.enable = true;
      home.packages = with pkgs; [
        wl-clipboard
        wofi
        font-awesome
        pavucontrol
        pulseaudio
        kitty
      ];
      wayland.windowManager.hyprland = {
        enable = true;

        settings = {
          exec-once = ''${startupScript}/bin/start'';

          # https://wiki.hyprland.org/Configuring/Uncommon-tips--tricks/
          input = {
            kb_layout = "gb";
          };

          "$mod" = "MOD4";
          bind = [
            "$mod, Enter, exec, kitty"
            "$mod, Space, exec, wofi --show run"

            "shift + $mod, 1, movetoworkspace, 1"
            "shift + $mod, 2, movetoworkspace, 2"
            "shift + $mod, 3, movetoworkspace, 3"
            "shift + $mod, 4, movetoworkspace, 4"
            "shift + $mod, 5, movetoworkspace, 5"
            "shift + $mod, 6, movetoworkspace, 6"
            "shift + $mod, 7, movetoworkspace, 7"

            "$mod, 1, workspace, 1"
            "$mod, 2, workspace, 2"
            "$mod, 3, workspace, 3"
            "$mod, 4, workspace, 4"
            "$mod, 5, workspace, 5"
            "$mod, 6, workspace, 6"
            "$mod, 7, workspace, 7"

            "$mod, h, movefocus, l"
            "$mod, j, movefocus, d"
            "$mod, k, movefocus, u"
            "$mod, l, movefocus, r"
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
