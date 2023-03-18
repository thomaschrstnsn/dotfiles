{ config, lib, pkgs, ... }:

with lib;

let
  theme = pkgs.callPackage ./tokyonight.nix { };
  skhd = ./skhd;
  cfg = config.tc.sketchybar;

  dimensions = {
    desktop = {
      font.small = 10;
      font.normal = 15;
      bar.height = 26;
    };
    laptop = {
      font.small = 10;
      font.normal = 14;
      bar.height = 24;
    };
  }.${cfg.scale};

  color_alpha = alpha: color: "0x${alpha}${color}";
  color_solid = color_alpha "ff";
  bar_trans = "44";

  default_padding = 10;

  bar_color = color_alpha bar_trans theme.background;
  label_color = icon_color;
  icon_color = color_solid theme.foreground;
  small_label_font = "JetBrainsMono Nerd Font:Regular:${toString dimensions.font.small}";
  icon_font = "JetBrainsMono Nerd Font:Regular:${toString dimensions.font.normal}";
  heavy_font = "JetBrainsMono Nerd Font:Bold Italic:${toString dimensions.font.normal}";
  icon_highlight_color = color_solid theme.yellow;
  label_highlight_color = icon_highlight_color;
  warning_highlight_color = color_solid theme.orange;
  label_font = icon_font;
  events.bluetooth_change = "bluetooth_change";

  background =
    {
      blur_radius = 50;
    };

  singleItemBracket = item:
    {
      bracket = "";
      items = [ item ];
    };

  scripts = ./sketchybar;

in
{
  options.tc.sketchybar = with types; {
    enable = mkEnableOption "sketchybar";
    yabai.event.title_change = mkOption { type = str; default = "title_change"; };
    yabai.event.window_focus = mkOption { type = str; default = "window_focus"; };
    spaces = mkOption {
      description = "Number of spaces";
      type = int;
      default = 20;
    };
    scale = mkOption {
      type = enum [ "desktop" "laptop" ];
    };
    position = mkOption {
      type = enum [ "top" "bottom" ];
    };
    aliases = {
      meetingbar.enable = mkEnableOption "MeetingBar Alias";
      appgate.enable = mkEnableOption "AppGate SDP Alias";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ jq choose ];

    launchd.user.agents.sketchybar.serviceConfig = {
      StandardErrorPath = "/tmp/sketchybar.log";
      StandardOutPath = "/tmp/sketchybar.log";
    };

    services.sketchybar = {
      enable = true;
      package = pkgs.sketchybar;
      config.bar = {
        height = dimensions.bar.height;
        position = cfg.position;
        padding_left = default_padding;
        padding_right = default_padding;
        topmost = "off";
        display = "main";
        corner_radius = 10;
        font_smoothing = "on";
        color = bar_color;
        blur_radius = background.blur_radius;
      };
      config.default = {
        cache_scripts = "on";
        "icon.font" = icon_font;
        "icon.color" = icon_color;
        "icon.highlight_color" = icon_highlight_color;
        "label.font" = label_font;
        "label.color" = label_color;
        "label.highlight_color" = label_highlight_color;
        "icon.padding_left" = default_padding;
        "icon.padding_right" = default_padding;
      } // background;
      config.spaces =
        map
          (i:
            let space = toString i;
            in
            {
              name = "space${space}";
              position = "left";
              attrs = {
                associated_display = 1;
                associated_space = "${space}";
                icon = "${space}";
                script = "${scripts}/space.sh";
                "label.padding_right" = 8;
                drawing = false;
              };
            })
          (genList (i: i + 1) cfg.spaces);
      config.events = [
        { name = cfg.yabai.event.title_change; }
        { name = cfg.yabai.event.window_focus; }
        { name = "yabai_layout"; }
        { name = events.bluetooth_change; notificationCenterEvent = "com.apple.bluetooth.status"; }
      ];
      config.items = [
        (singleItemBracket {
          name = "yabai_mode";
          position = "left";
          attrs = {
            script = "${scripts}/yabai-mode.sh";
            "background.color" = color_alpha bar_trans theme.orange;
          };
          subscribe = [ "yabai_layout" "space_change" ];
        })
        (singleItemBracket
          {
            # from https://github.com/FelixKratz/SketchyBar/discussions/12#discussioncomment-1633997
            name = "app_name";
            position = "left";
            attrs = {
              "label.font" = heavy_font;
              "label.color" = label_highlight_color;
              "label.padding_right" = default_padding;
            };
          }
        )
        (singleItemBracket
          {
            # from https://github.com/FelixKratz/SketchyBar/discussions/12#discussioncomment-1633997
            name = "window";
            position = "left";
            attrs = {
              script = "${scripts}/window-title.sh";
              "background.color" = color_solid theme.terminalBlack;
              "icon.drawing" = "off";
              "background.drawing" = "off";
            };
            subscribe = [ "window_focus" "title_change" "window" "front_app_switched" "space_change" ];
          }
        )
        (singleItemBracket
          {
            name = "clock";
            position = "right";
            attrs = {
              update_freq = 10;
              icon = "";
              script = "${scripts}/status.sh";
              "icon.padding_right" = 2;
              "label.padding_right" = 4;
            };
          }
        )
        (singleItemBracket
          {
            name = "date";
            position = "right";
            attrs = {
              icon = "";
              "label.padding_right" = default_padding;
              "background.color" = color_alpha bar_trans theme.orange;
            };
          }
        )
        (singleItemBracket
          {
            name = "Control Centre,Battery";
            itemType = "alias";
            position = "right";
            attrs = {
              # "background.padding_left" = -2;
              # "icon.padding_left" = -4;
              "background.padding_right" = -6;
              "icon.padding_right" = -8;
              "update_freq" = 10;
            };
          }
        )
        (singleItemBracket
          {
            name = "wifi";
            position = "right";
            attrs = {
              click_script = "${scripts}/click-wifi.sh";
            };
          }
        )
        {
          bracket = "ram";
          items = [
            {
              name = "label";
              position = "right";
              attrs = {
                "label.font" = small_label_font;
                label = "RAM";
                y_offset = 6;
                width = 0;
                "icon.padding_left" = 0;
              };
            }
            {
              name = "percentage";
              position = "right";
              attrs =
                {
                  "label.font" = small_label_font;
                  y_offset = -4;
                  script = "${scripts}/ram.sh";
                  update_freq = 1;
                  "icon.padding_left" = 0;
                };
            }
          ];
        }
        {
          bracket = "cpu";
          attrs = {
            "background.color" = color_alpha bar_trans theme.green;
          };
          items = [
            {
              name = "separator";
              position = "right";
              attrs = {
                "icon.drawing" = "off";
                "label.drawing" = "off";
                "background.padding_left" = 0;
                "background.padding_right" = 0;
              };
            }
            {
              name = "topproc";
              position = "right";
              attrs = {
                label = "CPU";
                "label.font" = small_label_font;
                "icon.drawing" = "off";
                width = 0;
                y_offset = 6;
                update_freq = 5;
                script = "${scripts}/topproc.sh";
              };
            }
            {
              name = "percent";
              position = "right";
              attrs = {
                "label.font" = label_font;
                label = "CPU";
                y_offset = -4;
                width = 40;
                "icon.drawing" = "off";
                update_freq = 2;
              };
            }
            {
              name = "sys";
              itemType = "graph";
              position = "right";
              graphWidth = 100;
              attrs = {
                width = 0;
                "graph.color" = warning_highlight_color;
                "graph.fill_color" = warning_highlight_color;
                "label.drawing" = "off";
                "icon.drawing" = "off";
              };
            }
            {
              name = "user";
              itemType = "graph";
              position = "right";
              graphWidth = 100;
              attrs = {
                "graph.color" = color_solid theme.cyan;
                update_freq = 2;
                "label.drawing" = "off";
                "icon.drawing" = "off";
                script = "${scripts}/cpu.sh";
              };
            }
          ];
        }
        {
          bracket = "network";
          items = [
            {
              name = "up";
              position = "right";
              attrs = {
                "label.font" = small_label_font;
                y_offset = 6;
                width = 0;
                script = "${scripts}/window-indicator.sh";
              };
              subscribe = [ "window_focus" "title_change" "window" "front_app_switched" "space_change" ];
            }
            {
              name = "down";
              position = "right";
              attrs =
                {
                  "label.font" = small_label_font;
                  y_offset = -4;
                };
            }
          ];
        }
        (mkIf cfg.aliases.meetingbar.enable
          (singleItemBracket
            {
              name = "MeetingBar";
              itemType = "alias";
              position = "right";
              attrs = {
                "background.padding_right" = -8;
                "background.padding_left" = -6;
                "icon.padding_left" = -16;
                "update_freq" = 10;
              };

            })
        )
        (mkIf cfg.aliases.appgate.enable
          (singleItemBracket
            {
              name = "Appgate SDP,Item-0";
              itemType = "alias";
              position = "right";
              attrs = {
                "background.padding_left" = -6;
                "icon.padding_left" = -16;
                "update_freq" = 10;
              };
            })
        )
        (singleItemBracket
          {
            name = "Control Centre,Sound";
            itemType = "alias";
            position = "right";
            attrs = {
              "background.padding_right" = -6;
              "icon.padding_right" = -8;
              "update_freq" = 10;
            };
          })

        ## TODO broken
        # (singleItemBracket
        #   {
        #     name = "headphones_item";
        #     position = "right";
        #     subscribe = [ events.bluetooth_change "mouse.clicked" ];
        #     attrs = {
        #       icon = "";
        #       script = "${scripts}/airpods_battery.sh";
        #       "icon.highlight_color" = warning_highlight_color;
        #     };
        #   }
        # )
        # {
        #   bracket = "headphones";
        #   items = [
        #     {
        #       name = "left";
        #       position = { popup = "headphones"; };
        #       attrs = {
        #         icon = "L";
        #       };
        #     }
        #     {
        #       name = "case";
        #       position = { popup = "headphones"; };
        #       attrs = {
        #         icon = "C";
        #       };
        #     }
        #     {
        #       name = "right";
        #       position = { popup = "headphones"; };
        #       attrs = {
        #         icon = "R";
        #       };
        #     }
        #   ];
        # }
      ];
    };

    services.sketchybar.extraConfig = ''
      # from https://github.com/FelixKratz/SketchyBar/discussions/12#discussioncomment-1633997

      sketchybar -m --update

      # ram disk
      cache="$HOME/.cache/sketchybar"
      mkdir -p "$cache"
      if ! mount | grep -qF "$cache"
      then
        disk=$(hdiutil attach -nobrowse -nomount ram://1024)
        disk="''${disk%% *}"
        newfs_hfs -v sketchybar "$disk"
        mount -t hfs -o nobrowse "$disk" "$cache"
      fi
    '';

    services.yabai.config = {
      external_bar =
        let
          value = toString (dimensions.bar.height);
        in
        "main:${if cfg.position == "top" then value else "0"}:${if cfg.position == "top" then "0" else value}";
    };

    system.defaults.NSGlobalDomain._HIHideMenuBar = true;
  };
}
