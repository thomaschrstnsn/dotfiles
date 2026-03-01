{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.tc.komorebi;

  # Default keybindings similar to aerospace style
  defaultGaps = {
    inner = 2;
    outer = {
      left = 2;
      right = 2;
      top = 2;
      bottom = 4;
    };
  };

  # Workspace labels (similar to aerospace)
  workspaces = stringToCharacters "bcegimnopqrtuvwxyz"; # minus hjkl and asdf

  workspaceBinds = ws: {
    "alt - ${ws}" = "focus-named-workspace ${ws}";
    "alt + shift - ${ws}" = "move-to-named-workspace ${ws}";
  };

  workspaceBindingsComplete = foldl' (acc: v: acc // v) { } (map workspaceBinds workspaces);

  toSkhdConfig = attrs: concatLines (mapAttrsToList (key: cmd: "${key}: komorebic ${cmd}") attrs);
in
{
  options.tc.komorebi = with types; {
    enable = mkEnableOption "komorebi tiling window manager for macOS https://github.com/LGUG2Z/komorebi-for-mac";

    logLevel = mkOption {
      type = enum [ "error" "warn" "info" "debug" "trace" ];
      default = "info";
      description = "Log verbosity level for komorebi";
    };

    gaps = {
      inner = mkOption {
        type = int;
        default = defaultGaps.inner;
        description = "Gap between windows in pixels";
      };
      outer = {
        left = mkOption {
          type = int;
          default = defaultGaps.outer.left;
          description = "Outer gap on the left side";
        };
        right = mkOption {
          type = int;
          default = defaultGaps.outer.right;
          description = "Outer gap on the right side";
        };
        top = mkOption {
          type = int;
          default = defaultGaps.outer.top;
          description = "Outer gap on the top";
        };
        bottom = mkOption {
          type = int;
          default = defaultGaps.outer.bottom;
          description = "Outer gap on the bottom";
        };
      };
    };

    bar = {
      enable = mkEnableOption "komorebi-bar status bar";

      monitors = mkOption {
        type = listOf int;
        default = [ 0 ];
        description = "List of monitor indices to show the bar on";
      };

      height = mkOption {
        type = int;
        default = 30;
        description = "Height of the bar in pixels";
      };

      font = {
        family = mkOption {
          type = str;
          default = "JetBrains Mono";
          description = "Font family for the bar";
        };
        size = mkOption {
          type = int;
          default = 12;
          description = "Font size for the bar";
        };
      };
    };

    extraConfig = mkOption {
      type = attrs;
      default = { };
      description = "Extra configuration to merge into the komorebi config";
    };

    bar.extraConfig = mkOption {
      type = attrs;
      default = { };
      description = "Extra configuration to merge into the komorebi-bar config";
    };
  };

  config = mkIf cfg.enable {
    services = {
      komorebi = {
        enable = true;
        logLevel = cfg.logLevel;

        config = mkMerge [
          {
            # Basic window management settings
            default_workspace_padding = cfg.gaps.inner;
            default_container_padding = cfg.gaps.inner;
            window_container_behaviour = "Create";
            mouse_follows_focus = true;

            # Gaps configuration
            global_work_area_offset = {
              left = cfg.gaps.outer.left;
              right = cfg.gaps.outer.right;
              top = cfg.gaps.outer.top;
              bottom = cfg.gaps.outer.bottom;
            };

            # Default monitor/workspace setup
            monitors = [
              {
                workspaces = map
                  (name: {
                    inherit name;
                    layout = "BSP";
                  })
                  workspaces;
              }
            ];
          }
          cfg.extraConfig
        ];
      };

      komorebi-bar = mkIf cfg.bar.enable {
        enable = true;

        bars = listToAttrs (map
          (monitor: {
            name = "monitor-${toString monitor}";
            value = {
              config = mkMerge [
                {
                  inherit monitor;
                  height = cfg.bar.height;
                  font_family = cfg.bar.font.family;
                  font_size = cfg.bar.font.size;

                  # Default widgets - komorebi workspaces on left
                  left_widgets = [
                    {
                      Komorebi = {
                        workspaces = {
                          enable = true;
                          hide_empty_workspaces = false;
                        };
                      };
                    }
                  ];
                  # Date and time on right
                  right_widgets = [
                    {
                      Date = {
                        enable = true;
                        format = "DayDateMonthYear";
                      };
                    }
                    {
                      Time = {
                        enable = true;
                        format = "TwentyFourHourWithoutSeconds";
                      };
                    }
                  ];
                }
                cfg.bar.extraConfig
              ];
            };
          })
          cfg.bar.monitors);
      };

      skhd.skhdConfig = toSkhdConfig ({
        # "hyper - q" = "move-workspace-to-monitor --wrap-around prev";
        # "hyper - w" = "move-workspace-to-monitor --wrap-around next";
        # "hyper - f" = "fullscreen";
        # "hyper - left" = "resize smart -50";
        # "hyper - right" = "resize smart +50";
        # "hyper - escape" = "reload-config";
        "alt - h" = " focus left";
        "alt - j" = " focus down";
        "alt - k" = " focus up";
        "alt - l" = " focus right";
        "alt + shift - 0x21" = " cycle-focus previous"; # 0x21 is [
        "alt + shift - 0x1E" = " cycle-focus next "; # 0x1E is ]
        "alt + shift - h" = " move left";
        "alt + shift - j" = " move down";
        "alt + shift - k" = " move up";
        "alt + shift - l" = " move right";
      } // workspaceBindingsComplete);
    };


    # System settings recommended for tiling WMs
    system.defaults = {
      # Disable animations for snappier window management
      NSGlobalDomain.NSAutomaticWindowAnimationsEnabled = false;
      # Enable separate spaces per display
      spaces.spans-displays = false;
    };
  };
}
