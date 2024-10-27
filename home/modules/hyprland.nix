{ pkgs, config, lib, ... }:
with lib; with builtins;

let
  cfg = config.tc.hyprland;
  startupScript = pkgs.pkgs.writeShellScriptBin "start" ''
    ${pkgs.waybar}/bin/waybar &
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
      ];
      wayland.windowManager.hyprland = {
        enable = true;

        settings = {
          exec-once = ''${startupScript}/bin/start'';

          # https://wiki.hyprland.org/Configuring/Uncommon-tips--tricks/
          input = {
            kb_layout = "gb";
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
              hyprpaster = ./hypr/paste_unless_wezterm.sh;
              hyprcopy = ./hypr/copy_unless_wezterm.sh;
              hyprundo = ./hypr/undo_unless_wezterm.sh;
            in
            concatLists [
              [
                "SUPER, Return, exec, wezterm"
                "SUPER, Space, exec, wofi --show run"
              ]
              (repeatBind "ALT, $KEY, workspace, name:$KEY" workspaceChars)
              (repeatBind "SHIFT + ALT, $KEY, movetoworkspacesilent, name:$KEY" workspaceChars)
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
                "SUPER, C, exec, ${hyprcopy}"
                "SUPER, V, exec, ${hyprpaster}"
                "SUPER, Z, exec, ${hyprundo}"
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
