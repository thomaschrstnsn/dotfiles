{ config, lib, ... }:
with lib;

let
  cfg = config.tc.hyprland;
in
{
  imports = [
    ./binds.nix
    ./desktop.nix
    ./lock-idle.nix
    ./settings.nix
  ];

  options.tc.hyprland = with types; {
    enable = mkEnableOption "hyprland";

    terminal = mkOption {
      type = enum [ "wezterm" "ghostty" ];
      description = "which terminal to use";
      default = "wezterm";
    };

    keyboard = mkOption {
      type = str;
      description = "which keyboard device to use (hyprctl devices)";
      example = "kanata";
    };

    kbLayout = mkOption {
      type = str;
      description = "xkb layout(s), comma separated";
      default = "gb,dk";
    };

    kbVariant = mkOption {
      type = str;
      description = "xkb variant(s), comma separated (empty for none)";
      default = "";
      example = "mac,mac";
    };

    clipboard = mkOption {
      type = enum [ "clipse" "noctalia" ];
      description = "which clipboard manager to employ";
      default = if cfg.shell == "noctalia" then "noctalia" else "clipse";
    };

    lockscreen = mkOption {
      type = enum [ "hyprlock" "noctalia" ];
      description = "which lockscreen to use";
      default = if cfg.shell == "noctalia" then "noctalia" else "hyprlock";
    };

    shell = mkOption {
      type = nullOr (enum [ "hyprpanel" "noctalia" ]);
      description = "which desktop shell to setup";
    };

    launcher = mkOption {
      type = enum [ "wofi" "noctalia" ];
      description = "which launcher to setup";
      default = if cfg.shell == "noctalia" then "noctalia" else "wofi";
    };

    screenshot = mkOption {
      type = enum [ "hyprshot" "noctalia" ];
      description = "which screenshot tool to use";
      default = if cfg.shell == "noctalia" then "noctalia" else "hyprshot";
    };

    hyprfocus.enable = mkEnableOption "use hyprfocus" // { default = true; };

    monitors = mkOption {
      type = listOf (attrsOf anything);
      description = ''
        monitor definitions (hl.monitor arguments), a catch-all
        `preferred`/`auto` entry is always appended
      '';
      default = [ ];
      example = [{ output = "HDMI-A-1"; mode = "5120x1440@240"; position = "0x0"; scale = "1"; }];
    };

    mainMonitor = mkOption {
      type = nullOr str;
      description = "monitor to pin the named workspaces and the cursor to";
      default = null;
      example = "HDMI-A-1";
    };

    vrr = mkOption {
      type = nullOr int;
      description = "misc:vrr setting (null leaves hyprland's default)";
      default = null;
    };

    layout = mkOption {
      type = enum [ "master" "dwindle" ];
      description = "default tiling layout (per workspace toggle with ALT + slash)";
      default = "master";
    };

    effects = mkOption {
      type = enum [ "full" "reduced-motion" "minimal" ];
      description = "reduced-motion disables animations; minimal also disables blur and shadows (for weak GPUs)";
      default = "full";
    };

    autostartTerminalOn = mkOption {
      type = nullOr str;
      description = "named workspace to start the terminal on at login";
      default = null;
      example = "t";
    };

    autostart = mkOption {
      type = listOf (submodule {
        options = {
          command = mkOption {
            type = str;
            description = "command to execute";
          };
          workspace = mkOption {
            type = nullOr str;
            description = "named workspace to (silently) start it on";
            default = null;
          };
        };
      });
      description = "commands to execute at login";
      default = [ ];
    };

    extraWindowRules = mkOption {
      type = listOf (attrsOf anything);
      description = "machine specific window rules (hl.window_rule arguments)";
      default = [ ];
    };

    devices = mkOption {
      type = listOf (attrsOf anything);
      description = "per-device input config (hl.device arguments)";
      default = [ ];
    };

    idle = {
      lock = mkOption {
        type = int;
        description = "seconds idle before locking";
        default = 120;
      };
      dpmsOff = mkOption {
        type = int;
        description = "seconds idle before turning off displays";
        default = 125;
      };
      suspend = mkOption {
        type = int;
        description = "seconds idle before suspending";
        default = 1500;
      };
    };

    laptop = {
      brightnessKeys = mkEnableOption "brightness keys (screen and keyboard backlight) via brightnessctl";
      touchpad = mkEnableOption "touchpad niceties: 3-finger workspace swipe, natural scroll, tap-to-click and clickfinger (press) clicks";
    };
  };
}
