{ config, lib, pkgs, ... }:

with lib;

let
  scripts = ./sketchybar;
  cfg = config.tc.sketchybar;
  bar_color = "0xff2e3440";
  label_color = icon_color;
  icon_color = "0xbbd8dee9";
  small_label_font = "MesloLGS Nerd Font:Regular:10.0";
  icon_font = "MesloLGS Nerd Font:Regular:13.0";
  heavy_font = "MesloLGS Nerd Font:Bold Italic:13.0";
  icon_highlight_color = "0xffebcb8b";
  label_highlight_color = icon_highlight_color;
  label_font = icon_font;
  events.bluetooth_change = "bluetooth_change";
in
{
  options.tc.sketchybar = with types; {
    enable = mkOption {
      description = "Enable sketchybar";
      type = bool;
      default = false;
    };
    yabai.event.title_change = mkOption { type = str; default = "title_change"; };
    yabai.event.window_focus = mkOption { type = str; default = "window_focus"; };
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
        height = 24;
        position = "bottom";
        padding_left = 10;
        padding_right = 10;
        color = bar_color;
        topmost = "on";
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
          (i: {
            name = "space${i}";
            position = "left";
            attrs = {
              associated_display = 1;
              associated_space = "${i}";
              icon = "${i}";
              click_script = "yabai -m space --focus ${i}";
              script = "${scripts}/space.sh";
            };
          })
          [ "1" "2" "3" "4" "5" "6" "7" "8" ];
      config.events = [
        { name = cfg.yabai.event.title_change; }
        { name = cfg.yabai.event.window_focus; }
        { name = events.bluetooth_change; notificationCenterEvent = "com.apple.bluetooth.status"; }
      ];
      config.items = [
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
          position = "left";
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
          name = "network";
          position = "right";
          attrs = {
            script = "${scripts}/window-indicator.sh";
          };
          subscribe = [ "space_change" ];
          # --default \
          #   icon.padding_left=0 \
          #   icon.padding_right=2 \
          #   label.padding_right=16 \
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
      external_bar = "main:0:26";
    };

    system.defaults.NSGlobalDomain._HIHideMenuBar = true;
  };
}
