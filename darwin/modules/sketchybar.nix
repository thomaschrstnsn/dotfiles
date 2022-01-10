{ config, lib, pkgs, ... }:

with lib;

let
  scripts = ./sketchybar;
  skhd = ./skhd;
  cfg = config.tc.sketchybar;

  dimensions = {
    desktop = {
      font.small = 11;
      font.normal = 15;
      bar.height = 26;
    };
    laptop = {
      font.small = 10;
      font.normal = 13;
      bar.height = 24;
    };
  }.${cfg.scale};

  bar_color = "0xff2e3440";
  label_color = icon_color;
  icon_color = "0xbbd8dee9";
  small_label_font = "JetBrainsMono Nerd Font:Regular:${toString dimensions.font.small}";
  icon_font = "JetBrainsMono Nerd Font:Regular:${toString dimensions.font.normal}";
  heavy_font = "JetBrainsMono Nerd Font:Bold Italic:${toString dimensions.font.normal}";
  icon_highlight_color = "0xffebcb8b";
  label_highlight_color = icon_highlight_color;
  label_font = icon_font;
  events.bluetooth_change = "bluetooth_change";
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
  };

  config = mkIf (cfg.enable) {
    environment.systemPackages = [ pkgs.jq ];

    # launchd.user.agents.sketchybar.serviceConfig = {
    #   StandardErrorPath = "/tmp/sketchybar.log";
    #   StandardOutPath = "/tmp/sketchybar.log";
    # };

    services.sketchybar = {
      enable = true;
      package = pkgs.sketchybar;
      config.bar = {
        height = dimensions.bar.height;
        position = "bottom";
        padding_left = 10;
        padding_right = 10;
        color = bar_color;
        topmost = "on";
        display = "main";
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
        "icon.padding_right" = 6;
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
        {
          name = "yabai_mode";
          position = "left";
          attrs = {
            script = "${scripts}/yabai-mode.sh";
          };
          subscribe = [ "yabai_layout" "space_change" ];
        }
        {
          # from https://github.com/FelixKratz/SketchyBar/discussions/12#discussioncomment-1633997
          name = "app_name";
          position = "left";
          attrs = {
            "label.font" = heavy_font;
            "label.color" = label_highlight_color;
          };
        }
        {
          # from https://github.com/FelixKratz/SketchyBar/discussions/12#discussioncomment-1633997
          name = "window";
          position = "center";
          attrs = {
            script = "${scripts}/window-title.sh";
          };
          subscribe = [ "window_focus" "title_change" "window" "front_app_switched" "space_change" ];
        }
        {
          name = "clock";
          position = "right";
          attrs = {
            update_freq = 10;
            script = "${scripts}/status.sh";
            "icon.padding_left" = 2;
          };
        }
        {
          name = "battery";
          position = "right";
          attrs = {
            update_freq = 60;
            script = "${scripts}/battery.sh";
          };
        }
        {
          name = "wifi";
          position = "right";
          attrs = {
            click_script = "${scripts}/click-wifi.sh";
          };
        }
        {
          name = "ram_label";
          position = "right";
          attrs = {
            "label.font" = small_label_font;
            label = "RAM";
            y_offset = 6;
            width = 0;
          };
        }
        {
          name = "ram_percentage";
          position = "right";
          attrs =
            {
              "label.font" = small_label_font;
              y_offset = -4;
              script = "${scripts}/ram.sh";
              update_freq = 1;
            };
        }
        {
          name = "cpu_label";
          position = "right";
          attrs = {
            "label.font" = small_label_font;
            label = "CPU";
            y_offset = 6;
            width = 0;
          };
        }
        {
          name = "cpu_percentage";
          position = "right";
          attrs =
            {
              "label.font" = small_label_font;
              y_offset = -4;
              script = "${scripts}/cpu.sh";
              update_freq = 1;
            };
        }
        {
          name = "network_up";
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
          name = "network_down";
          position = "right";
          attrs =
            {
              "label.font" = small_label_font;
              y_offset = -4;
            };
        }
        {
          name = "headphones";
          position = "right";
          subscribe = [ events.bluetooth_change ];
          attrs = {
            icon = "";
            script = "${scripts}/airpods_battery.sh";
          };
        }
      ];
    };

    services.sketchybar.extraConfig = ''
      #!/bin/bash

      # from https://github.com/FelixKratz/SketchyBar/discussions/12#discussioncomment-1633997

      # sketchybar -m \
      #     --add bracket app_window \
      #         app_name window \
      #     --set app_window \
      #         background.drawing=off

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
      external_bar = "main:0:${toString (dimensions.bar.height + 2)}";
    };

    system.defaults.NSGlobalDomain._HIHideMenuBar = true;
  };
}
