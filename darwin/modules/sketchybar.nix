{ config, lib, pkgs, ... }:

with lib;

let
  theme = pkgs.callPackage ./nord-theme.nix { };
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

  colorAlpha = alpha: color: "0x${alpha}${color}";
  colorSolid = colorAlpha "ff";

  bar_color = colorAlpha "44" theme.nord0;
  label_color = icon_color;
  icon_color = colorSolid theme.white;
  small_label_font = "JetBrainsMono Nerd Font:Regular:${toString dimensions.font.small}";
  icon_font = "JetBrainsMono Nerd Font:Regular:${toString dimensions.font.normal}";
  heavy_font = "JetBrainsMono Nerd Font:Bold Italic:${toString dimensions.font.normal}";
  icon_highlight_color = colorSolid theme.yellow;
  label_highlight_color = icon_highlight_color;
  warning_highlight_color = colorSolid theme.orange;
  label_font = icon_font;
  events.bluetooth_change = "bluetooth_change";

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
      default = 8;
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

  config = mkIf (cfg.enable) {
    environment.systemPackages = [ pkgs.jq ];

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
        padding_left = 10;
        padding_right = 10;
        color = bar_color;
        topmost = "off";
        display = "main";
        corner_radius = 10;
        blur_radius = 50;
        font_smoothing = "on";
      };
      config.default = {
        cache_scripts = "on";
        "icon.font" = icon_font;
        "icon.color" = icon_color;
        "icon.highlight_color" = icon_highlight_color;
        "label.font" = label_font;
        "label.color" = label_color;
        "label.highlight_color" = label_highlight_color;
        "icon.padding_left" = 10;
        "icon.padding_right" = 10;
      };
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
                click_script = "${skhd}/focusFirstWindowInSpace.sh ${space}";
                script = "${scripts}/space.sh";
                "label.padding_right" = 8;
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
            "background.color" = colorSolid theme.orange;
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
              "label.padding_right" = 10;
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
              "background.color" = colorSolid theme.nord15;
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
              script = "${scripts}/status.sh";
              "icon.padding_left" = 2;
            };
          }
        )
        (singleItemBracket
          {
            name = "battery";
            position = "right";
            attrs = {
              update_freq = 60;
              script = "${scripts}/battery.sh";
              "icon.highlight_color" = warning_highlight_color;
              "label.highlight_color" = warning_highlight_color;
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
                };
            }
          ];
        }
        {
          bracket = "cpu";
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
                "graph.color" = colorSolid theme.nord10;
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
        (mkIf (cfg.aliases.meetingbar.enable)
          (singleItemBracket
            {
              name = "MeetingBar";
              itemType = "alias";
              position = "right";
              attrs = {
                "background.color" = bar_color;
                "background.padding_right" = -8;
                "background.padding_left" = -6;
                "icon.padding_left" = -16;
                "update_freq" = 10;
              };

            })
        )
        (mkIf (cfg.aliases.appgate.enable)
          (singleItemBracket
            {
              name = "Appgate SDP,Item-0";
              itemType = "alias";
              position = "right";
              attrs = {
                "background.color" = bar_color;
                "background.padding_left" = -6;
                "icon.padding_left" = -16;
                "update_freq" = 10;
              };
            })
        )
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
