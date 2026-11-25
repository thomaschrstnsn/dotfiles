# Core hyprland configuration: look, input, monitors, workspaces, rules and autostart.
# Keybindings live in ./binds.nix
{ pkgs, config, lib, ... }:
with lib; with builtins;

let
  mkLuaInline = generators.mkLuaInline;

  mkIfList = cond: xs: if cond then xs else [ ];

  cfg = config.tc.hyprland;

  inherit (import ./commands.nix { inherit pkgs cfg; }) clipseClass lockCmd;

  minimalEffects = cfg.effects == "minimal";
  noAnimations = cfg.effects != "full";

  cursor.size = 32;

  withMainMonitor = attrs:
    attrs // optionalAttrs (cfg.mainMonitor != null) { monitor = cfg.mainMonitor; };

  # lines (indented for the hyprland.start function body) starting the autostart programs
  autostartLines = concatMapStrings (l: "  ${l}\n") (concatLists [
    (optional (cfg.autostartTerminalOn != null)
      ''hl.exec_cmd(terminal, { workspace = "name:${cfg.autostartTerminalOn} silent" })'')
    (map
      (a:
        if a.workspace == null
        then ''hl.exec_cmd("${a.command}")''
        else ''hl.exec_cmd("${a.command}", { workspace = "name:${a.workspace} silent" })'')
      cfg.autostart)
  ]);
in
{
  config = mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      configType = "lua";

      settings = {
        hyper = {
          _var = "SUPER+SHIFT+CTRL+ALT";
        };

        terminal = {
          _var = cfg.terminal;
        };

        config = {
          ecosystem.no_update_news = true;

          input = {
            kb_layout = cfg.kbLayout;
            repeat_rate = 35;
            repeat_delay = 350;
            touchpad = {
              scroll_factor = 0.5;
              drag_lock = true;
            } // optionalAttrs cfg.laptop.touchpad {
              natural_scroll = true;
              tap_to_click = true;
              # physical press: 1/2/3 fingers = left/right/middle click anywhere
              # (libinput's Apple default) instead of bottom button areas
              clickfinger_behavior = true;
            };
          } // optionalAttrs (cfg.kbVariant != "") {
            kb_variant = cfg.kbVariant;
          };

          decoration = {
            rounding = 20;
            rounding_power = 2;

            # Change transparency of focused and unfocused windows
            active_opacity = 1.0;
            inactive_opacity = 1.0;

            shadow = {
              enabled = !minimalEffects;
              color = "rgba(1a1a1aee)";
              range = 4;
              render_power = 3;
            };

            blur = {
              enabled = !minimalEffects;
              size = 3;
              passes = 2;
              vibrancy = 0.1696;
            };
          };

          general = {
            border_size = 3;
            resize_on_border = true;
            gaps_in = 5;
            gaps_out = 5;

            layout = cfg.layout;
          };

          master = {
            mfact = 0.5;
            orientation = "center";
            slave_count_for_center_master = 0;
            center_master_fallback = "right";
          };

          cursor = {
            inactive_timeout = 3;
          } // optionalAttrs (cfg.mainMonitor != null) {
            default_monitor = cfg.mainMonitor;
          };

          misc = {
            key_press_enables_dpms = true;
            disable_hyprland_logo = true;
          } // optionalAttrs (cfg.vrr != null) {
            vrr = cfg.vrr;
          };

          binds.workspace_center_on = true;
        } // optionalAttrs noAnimations {
          animations.enabled = false;
        };

        env = [
          {
            _args = [
              "HYPRCURSOR_SIZE"
              (toString cursor.size)
            ];
          }
          {
            _args = [
              "XCURSOR_SIZE"
              (toString cursor.size)
            ];
          }
        ];

        on = {
          _args = [
            "hyprland.start"
            (mkLuaInline ''
              function()
                hl.exec_cmd("hyprctl setcursor Bibata-Modern-Classic 32")
                hl.exec_cmd("${lockCmd}")
                hl.exec_cmd("${./hypr/layout_watcher.sh} ${cfg.layout}")
              ${autostartLines}  ${if cfg.shell == "hyprpanel" then ''hl.exec_cmd("${pkgs.hyprpanel}/bin/hyprpanel")'' else ""}
                ${if cfg.clipboard == "clipse" then ''hl.exec_cmd("clipse -listen")'' else ""}
                ${if cfg.shell == "noctalia" then ''hl.exec_cmd("noctalia")'' else ""}
              end
            '')
          ];
        };

        monitor = cfg.monitors ++ [
          {
            output = "";
            mode = "preferred";
            position = "auto";
            scale = "1";
          }
        ];

        workspace_rule = map withMainMonitor [
          { workspace = "name:t"; default = true; persistent = true; }
          { workspace = "name:u"; persistent = true; }
          { workspace = "name:b"; persistent = true; }
          { workspace = "name:p"; persistent = true; layout = "dwindle"; }
          { workspace = "name:c"; persistent = true; }
          { workspace = "name:m"; persistent = true; }
        ];

        curve = [
          { _args = [ "easeOutBack" { type = "bezier"; points = [ [ 0.34 1.56 ] [ 0.64 1 ] ]; } ]; }
          { _args = [ "easeInBack" { type = "bezier"; points = [ [ 0.36 0 ] [ 0.66 (-0.56) ] ]; } ]; }
          { _args = [ "easeInCubic" { type = "bezier"; points = [ [ 0.32 0 ] [ 0.67 0 ] ]; } ]; }
          { _args = [ "easeInOutCubic" { type = "bezier"; points = [ [ 0.65 0 ] [ 0.35 1 ] ]; } ]; }
        ];

        animation = [
          { leaf = "windowsIn"; enabled = true; speed = 1; bezier = "easeOutBack"; style = "popin"; }
          { leaf = "windowsOut"; enabled = true; speed = 1; bezier = "easeInBack"; style = "popin"; }
          { leaf = "fadeIn"; enabled = false; }
          { leaf = "fadeOut"; enabled = true; speed = 2; bezier = "easeInCubic"; }
          { leaf = "workspaces"; enabled = true; speed = 1; bezier = "easeInOutCubic"; style = "slide"; }
        ];

        window_rule =
          let
            settingsAndPreviews = builtins.concatStringsSep "|"
              [ "org.pulseaudio.pavucontrol" "blueberry.py" "Impala" "org.gnome.NautilusPreviewer" "io.github.kaii_lb.Overskride" ];
            filePickers = builtins.concatStringsSep "|"
              [ "Open.*Files?" "Save.*Files?" "All Files" "Save" ];
          in
          concatLists [
            [
              ## inspired by https://github.com/basecamp/omarchy/blob/master/default/hypr/windows.conf
              # Float and center settings and previews
              { match = { class = "^(${settingsAndPreviews})$"; }; float = true; }
              { match = { class = "^(${settingsAndPreviews})$"; }; size = [ 1024 768 ]; }
              { match = { class = "^(${settingsAndPreviews})$"; }; center = true; }

              # Float and center file pickers
              { match = { class = "xdg-desktop-portal-gtk"; title = "^(${filePickers})"; }; float = true; }
              { match = { class = "xdg-desktop-portal-gtk"; title = "^(${filePickers})"; }; center = true; }
            ]
            cfg.extraWindowRules
            [
              { match = { class = ".*"; }; idle_inhibit = "fullscreen"; } # idle inhibit whenever something is fullscreen (possible workaround for regression: https://github.com/hyprwm/Hyprland/issues/9170 )
              { match = { class = "zen"; }; focus_on_activate = true; } # should allow zen to take focus
            ]
            (mkIfList (cfg.clipboard == "clipse") [
              { match = { class = clipseClass; }; float = true; } # ensure you have a floating window class set if you want this behavior
              { match = { class = clipseClass; }; size = [ 622 652 ]; } # set the size of the window as necessary
            ])
          ];
      } // optionalAttrs (cfg.devices != [ ]) {
        device = cfg.devices;
      } // optionalAttrs cfg.laptop.touchpad {
        gesture = [
          { fingers = 3; direction = "horizontal"; action = "workspace"; }
        ];
      };
    };
  };
}
