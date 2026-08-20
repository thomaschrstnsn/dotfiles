{ pkgs, config, lib, ... }:
with lib; with builtins;

let
  mkLuaInline = generators.mkLuaInline;

  mkIfList = cond: xs: if cond then xs else [ ];

  cfg = config.tc.hyprland;

  cursor.size = 32;

  clipseClass = "name.savedra1.clipse";

  terminal = {
    executable = term: term;
    class = term: {
      wezterm = "org.wezfurlong.wezterm";
      ghostty = "com.mitchellh.ghostty";
    }.${term};
    starter = term: { class, command }: {
      wezterm = "wezterm start --class ${class} -e '${command}'";
      ghostty = "ghostty --class=${class} -e '${command}'";
    }.${term};
  };

  webapp = {
    starter = app: "${pkgs.gtk3}/bin/gtk-launch ${app}.desktop";
    # class = app: "webapp-${app}";
  };

  hyprlockFix = pkgs.writeShellApplication {
    name = "hyprlock-fix";
    text = ''
      pkill -9 hyprlock
      hyprctl --instance 0 eval 'hl.clear_crashed_lockscreen()'
    '';
  };

  mainMonitor = "HDMI-A-1";

  workspaceChars = stringToCharacters ("123456789" + "qwertyuiop" + "zxcvbnm");

  focusWsBinds = map
    (k: {
      _args = [
        "ALT + ${k}"
        (mkLuaInline ''hl.dsp.focus({ workspace = "name:${k}" })'')
      ];
    })
    workspaceChars;

  moveWsBinds = map
    (k: {
      _args = [
        "SHIFT + ALT + ${k}"
        (mkLuaInline ''hl.dsp.window.move({ workspace = "name:${k}" })'')
      ];
    })
    workspaceChars;

  moveWsSilentBinds = map
    (k: {
      _args = [
        "CTRL + ALT + ${k}"
        (mkLuaInline ''hl.dsp.window.move({ workspace = "name:${k}", follow = false })'')
      ];
    })
    workspaceChars;
in
{
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

    clipboard = mkOption {
      type = enum [ "clipse" "dms" ];
      description = "which clipboard manager to employ";
      default = "dms";
    };

    shell = mkOption {
      type = nullOr (enum [ "hyprpanel" "dms" "noctalia" ]);
      description = "which desktop shell to setup";
    };

    hyprfocus.enable = mkEnableOption "use hyprfocus" // { default = true; };
  };
  config = mkIf cfg.enable
    {
      fonts.fontconfig.enable = true;

      # check up on font installation nixos vs home-manager: https://nixos.wiki/wiki/Fonts
      # fonts.packages = with pkgs; [];

      home.packages = with pkgs; (concatLists [
        [
          hyprlockFix
          myPkgs.appleFonts.sf-pro
          bemoji # emoji picker
          nerd-fonts.jetbrains-mono
          noto-fonts
          font-awesome
          hyprshot
          jq # for scripts
          libnotify
          overskride # bluetooth
          openhue-cli
          pavucontrol
          pulseaudio
          wl-clipboard
          wtype # dep for bemoji
        ]
        (mkIfList (cfg.shell == "hyprpanel") [
          hyprpanel
          python312Packages.gpustat
        ])
        (mkIfList (cfg.clipboard == "clipse") [ clipse ])
        (mkIfList cfg.hyprfocus.enable [ myPkgs.hyprfocus ])
      ]);

      dconf = {
        enable = true;
        settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
      };

      programs.wofi = {
        enable = true;
        style = readFile ./wofi/style.css;
      };

      gtk = rec {
        enable = true;
        gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;

        cursorTheme = {
          name = "Bibata-Modern-Classic";
          package = pkgs.bibata-cursors;
        };

        # does not seem fully baked, seems to need env
        # GTK_THEME=Adwaita:dark nautilus
        # GTK_THEME=Adwaita:dark gnome-calculator
        theme = {
          name = "Adwaita-dark";
          package = pkgs.gnome-themes-extra;
        };

        gtk4.theme = theme;
      };

      programs.hyprlock = {
        enable = true;
        settings = {
          # based on https://github.com/MrVivekRajan/Hyprlock-Styles/blob/main/Style-3/hyprlock.conf
          general = {
            disable_loading_bar = false;
            no_fade_in = false;
          };

          background = [
            {
              path = "~/Pictures/WallDiscovery/wallhaven.cc/lqkr2q.jpeg";
              blur_passes = 3;
              contrast = 0.9;
              brightness = 0.8;
              vibrancy = 0.2;
              vibrancy_darkness = 0.0;
            }
          ];

          label = [
            # day month date
            {
              text = "cmd[update:1000] echo $(date +'%A, %B %d')";
              font_size = 25;
              color = "rgba(216, 222, 233, 0.70)";
              font_family = "SF Pro Display Bold";
              position = "0, 350";
              halign = "center";
              valign = "center";
            }
            # time
            {
              text = ''cmd[update:1000] echo "<span>$(date +"%H:%M")</span>"'';
              font_size = 120;
              color = "rgba(216, 222, 233, 0.70)";
              font_family = "SF Pro Display Bold";
              position = "0, 250";
              halign = "center";
              valign = "center";
            }
            # user
            {
              text = "    $USER";
              color = "rgba(216, 222, 233, 0.80)";
              outline_thickness = 2;
              dots_size = 0.2;
              dots_spacing = 0.2;
              dots_center = true;
              font_size = 18;
              font_family = "SF Pro Display Bold";
              position = "0, -130";
              halign = "center";
              valign = "center";
            }
          ];

          shape =
            {
              # USER-BOX
              size = "300, 60";
              color = "rgba(255, 255, 255, .1)";
              rounding = -1;
              border_size = 0;
              border_color = "rgba(253, 198, 135, 0)";
              rotate = 0;
              xray = false; # if true, make a "hole" in the background (rectangle of specified size, no rotation)
              position = "0, -130";
              halign = "center";
              valign = "center";
            };

          input-field = {
            size = "300, 60";
            outline_thickness = 2;
            dots_size = 0.2;
            dots_spacing = 0.2;
            dots_center = true;
            outer_color = "rgba(0, 0, 0, 0)";
            inner_color = "rgba(255, 255, 255, 0.1)";
            font_color = "rgb(200, 200, 200)";
            fade_on_empty = false;
            font_family = "SF Pro Display Bold";
            placeholder_text = ''🔒 <i><span foreground="##ffffff99">Enter Pass</span></i>'';
            hide_input = false;
            position = "0, -210";
            halign = "center";
            valign = "center";
          };
        };
      };

      services.hypridle = {
        enable = true;
        settings = {
          general = {
            lock_cmd = "pidof hyprlock || env WLR_EGL_NO_MODIFIERS=1 hyprlock";
            before_sleep_cmd = "loginctl lock-session";
            after_sleep_cmd = "hyprctl dispatch 'hl.dsp.dpms({ action = \"on\" })'";
            ignore_dbus_inhibit = false;
          };

          listener = [
            {
              timeout = 120;
              on-timeout = "loginctl lock-session";
            }
            {
              timeout = 125;
              on-timeout = "hyprctl dispatch 'hl.dsp.dpms({ action = \"off\" })'";
              on-resume = "hyprctl dispatch 'hl.dsp.dpms({ action = \"on\" })'";
            }
            {
              # timeout = 240;
              timeout = 1500;
              on-timeout = "systemctl suspend";
            }
          ];
        };
      };

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
              kb_layout = "gb,dk";
              repeat_rate = 35;
              repeat_delay = 350;
              touchpad = {
                scroll_factor = 0.5;
                drag_lock = true;
              };
            };

            decoration = {
              rounding = 20;
              rounding_power = 2;

              # Change transparency of focused and unfocused windows
              active_opacity = 1.0;
              inactive_opacity = 1.0;

              shadow = {
                enabled = true;
                color = "rgba(1a1a1aee)";
                range = 4;
                render_power = 3;
              };

              blur = {
                enabled = true;
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

              layout = "master";
            };

            master = {
              mfact = 0.5;
              orientation = "center";
              slave_count_for_center_master = 0;
              center_master_fallback = "right";
            };

            cursor = {
              inactive_timeout = 3;
              default_monitor = mainMonitor;
            };

            misc = {
              key_press_enables_dpms = true;
              vrr = 2;
              disable_hyprland_logo = true;
            };

            binds.workspace_center_on = true;
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
                  hl.exec_cmd("hyprlock")
                  hl.exec_cmd("${./hypr/layout_watcher.sh}")
                  hl.exec_cmd(terminal, { workspace = "name:t silent" })
                  hl.exec_cmd("zen", { workspace = "name:b silent" })
                  hl.exec_cmd("todoist-electron", { workspace = "name:p silent" })
                  hl.exec_cmd("1password", { workspace = "name:p silent" })
                  hl.exec_cmd("spotify", { workspace = "name:m silent" })
                  ${if cfg.shell == "hyprpanel" then ''hl.exec_cmd("${pkgs.hyprpanel}/bin/hyprpanel")'' else ""}
                  ${if cfg.clipboard == "clipse" then ''hl.exec_cmd("clipse -listen")'' else ""}
                  ${if cfg.shell == "noctalia" then ''hl.exec_cmd("noctalia-shell")'' else ""}
                end
              '')
            ];
          };

          monitor = [
            # "HDMI-A-1, 5120x1440@240, 0x0, 1, vrr, 1, bitdepth, 10"
            {
              output = mainMonitor;
              mode = "5120x1440@240";
              position = "0x0";
              scale = "1";
              bitdepth = 10;
            }
            {
              output = "";
              mode = "preferred";
              position = "auto";
              scale = "1";
            }
          ];

          device = [
            {
              name = "thomas’-pegefelt-(gamle)";
              sensitivity = 0.4;
              natural_scroll = true;
            }
          ];

          workspace_rule = [
            { workspace = "name:t"; monitor = mainMonitor; default = true; persistent = true; }
            { workspace = "name:u"; monitor = mainMonitor; persistent = true; }
            { workspace = "name:b"; monitor = mainMonitor; persistent = true; }
            { workspace = "name:p"; monitor = mainMonitor; persistent = true; layout = "dwindle"; }
            { workspace = "name:c"; monitor = mainMonitor; persistent = true; }
            { workspace = "name:m"; monitor = mainMonitor; persistent = true; }
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

                # Float Steam windows, except primary
                { match = { class = "steam"; }; float = true; }
                { match = { class = "steam"; title = "Steam"; }; tile = true; }

                { match = { class = "^(path of building.exe)"; }; tile = true; }
                { match = { class = "^(path of building-poe2.exe)"; }; tile = true; }
              ]
              [
                { match = { class = ".*"; }; idle_inhibit = "fullscreen"; } # idle inhibit whenever something is fullscreen (possible workaround for regression: https://github.com/hyprwm/Hyprland/issues/9170 )
                { match = { class = "zen"; }; focus_on_activate = true; } # should allow zen to take focus
              ]
              (mkIfList (cfg.clipboard == "clipse") [
                { match = { class = clipseClass; }; float = true; } # ensure you have a floating window class set if you want this behavior
                { match = { class = clipseClass; }; size = [ 622 652 ]; } # set the size of the window as necessary
              ])
            ];

          bind =
            let
              clipboardCmd = {
                clipse = "${terminal.starter cfg.terminal {class = clipseClass; command = "clipse";}}";
                dms = "dms ipc call clipboard toggle";
              }."${cfg.clipboard}";
            in
            concatLists
              [
                [
                  # SUPER + q enters a short-lived "kill" submap: subsequent presses
                  # within 300 ms close the active window, then the submap resets.
                  { _args = [ "SUPER + q" (mkLuaInline ''hl.dsp.submap("kill")'') ]; }
                  { _args = [ "SUPER + q" (mkLuaInline ''function() hl.timer(function() hl.dsp.submap("reset") end, { timeout = 300, type = "oneshot" }) end'') ]; }
                ]
                [{ _args = [ "SUPER + mouse:272" (mkLuaInline "hl.dsp.window.drag()") { mouse = true; } ]; }]
                [
                  { _args = [ "SUPER + Return" (mkLuaInline "hl.dsp.exec_cmd(terminal)") ]; }
                  { _args = [ "SUPER + Space" (mkLuaInline ''hl.dsp.exec_cmd("pgrep wofi || wofi --show run")'') ]; }
                  { _args = [ (mkLuaInline ''hyper .. " + f"'') (mkLuaInline "hl.dsp.window.fullscreen()") ]; }
                  { _args = [ "SHIFT + SUPER + f" (mkLuaInline "hl.dsp.window.float()") ]; }
                  { _args = [ "CTRL + SUPER + q" (mkLuaInline ''hl.dsp.exec_cmd("pidof hyprlock || env WLR_EGL_NO_MODIFIERS=1 hyprlock")'') ]; }
                  { _args = [ "SHIFT + SUPER + 4" (mkLuaInline ''hl.dsp.exec_cmd("hyprshot -m region --clipboard-only")'') ]; }
                  { _args = [ "SHIFT + SUPER + 3" (mkLuaInline ''hl.dsp.exec_cmd("hyprshot -m window --clipboard-only")'') ]; }
                ]
                (mkIfList (cfg.shell == "hyprpanel") [
                  { _args = [ "CTRL + Escape" (mkLuaInline ''hl.dsp.exec_cmd("${pkgs.hyprpanel}/bin/hyprpanel t verification")'') ]; }
                  { _args = [ "CTRL + SHIFT + Escape" (mkLuaInline ''hl.dsp.exec_cmd("${pkgs.hyprpanel}/bin/hyprpanel t powerdropdownmenu")'') ]; }
                ])
                (mkIfList (cfg.shell == "dms") [
                  { _args = [ "CTRL + Escape" (mkLuaInline ''hl.dsp.exec_cmd("${pkgs.dms-shell}/bin/dms ipc call powermenu toggle")'') ]; }
                ])
                (mkIfList (cfg.shell == "noctalia") [
                  { _args = [ "CTRL + Escape" (mkLuaInline ''hl.dsp.exec_cmd("noctalia-shell ipc call sessionMenu toggle")'') ]; }
                ])
                # mediakeys
                [
                  { _args = [ "XF86AudioRaiseVolume" (mkLuaInline ''hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ +10%")'') ]; }
                  { _args = [ "XF86AudioLowerVolume" (mkLuaInline ''hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ -10%")'') ]; }
                  { _args = [ "XF86AudioMute" (mkLuaInline ''hl.dsp.exec_cmd("pactl set-sink-mute @DEFAULT_SINK@ toggle")'') ]; }
                  { _args = [ "XF86AudioMicMute" (mkLuaInline ''hl.dsp.exec_cmd("pactl set-source-mute @DEFAULT_SOURCE@ toggle")'') ]; }
                ]
                focusWsBinds
                moveWsBinds
                moveWsSilentBinds
                [
                  { _args = [ "ALT + h" (mkLuaInline ''hl.dsp.focus({ direction = "left" })'') ]; }
                  { _args = [ "ALT + j" (mkLuaInline ''hl.dsp.focus({ direction = "down" })'') ]; }
                  { _args = [ "ALT + k" (mkLuaInline ''hl.dsp.focus({ direction = "up" })'') ]; }
                  { _args = [ "ALT + l" (mkLuaInline ''hl.dsp.focus({ direction = "right" })'') ]; }

                  { _args = [ "ALT + SHIFT + h" (mkLuaInline ''hl.dsp.window.swap({ direction = "left" })'') ]; }
                  { _args = [ "ALT + SHIFT + j" (mkLuaInline ''hl.dsp.window.swap({ direction = "down" })'') ]; }
                  { _args = [ "ALT + SHIFT + k" (mkLuaInline ''hl.dsp.window.swap({ direction = "up" })'') ]; }
                  { _args = [ "ALT + SHIFT + l" (mkLuaInline ''hl.dsp.window.swap({ direction = "right" })'') ]; }

                  { _args = [ (mkLuaInline ''hyper .. " + q"'') (mkLuaInline ''hl.dsp.workspace.move({ monitor = "l" })'') ]; }
                  { _args = [ (mkLuaInline ''hyper .. " + w"'') (mkLuaInline ''hl.dsp.workspace.move({ monitor = "r" })'') ]; }
                ]
                (if cfg.hyprfocus.enable then [
                  { _args = [ (mkLuaInline ''hyper .. " + b"'') (mkLuaInline ''hl.dsp.exec_cmd("${pkgs.myPkgs.hyprfocus}/bin/hyprfocus initial-title \"Zen Browser\" start zen")'') ]; }
                  { _args = [ (mkLuaInline ''hyper .. " + t"'') (mkLuaInline ''hl.dsp.exec_cmd("${pkgs.myPkgs.hyprfocus}/bin/hyprfocus initial-class ${terminal.class cfg.terminal} start \"${terminal.executable cfg.terminal}\"")'') ]; }
                  { _args = [ (mkLuaInline ''hyper .. " + p"'') (mkLuaInline ''hl.dsp.exec_cmd("${pkgs.myPkgs.hyprfocus}/bin/hyprfocus initial-class \"Todoist\" start todoist-electron")'') ]; }
                ] else
                  (mapAttrsToList
                    (key: window: {
                      _args = [
                        (mkLuaInline ''hyper .. " + ${key}"'')
                        (mkLuaInline ''hl.dsp.focus({ window = "class:${window}" })'')
                      ];
                    })
                    {
                      t = terminal.class cfg.terminal;
                      p = "Todoist";
                      # g = webapp.class "claude";
                      # c = webapp.class "icloud-calendar";
                    }) ++
                  [
                    { _args = [ (mkLuaInline ''hyper .. " + b"'') (mkLuaInline ''hl.dsp.focus({ window = "initialtitle:Zen Browser" })'') ]; }
                  ]
                )
                [
                  # copy/paste using super
                  { _args = [ "SUPER + C" (mkLuaInline ''hl.dsp.exec_cmd("${./hypr/copy_unless_term.sh}")'') ]; }
                  { _args = [ "SUPER + V" (mkLuaInline ''hl.dsp.exec_cmd("${./hypr/paste_unless_term.sh}")'') ]; }
                  { _args = [ "SUPER + Z" (mkLuaInline ''hl.dsp.exec_cmd("${./hypr/undo_unless_term.sh}")'') ]; }
                  { _args = [ "SUPER + SHIFT + C" (mkLuaInline ''hl.dsp.exec_cmd("${clipboardCmd}")'') ]; }
                  # "ALT, comma, exec, <reserved for giphy picker>"
                  { _args = [ "ALT + period" (mkLuaInline ''hl.dsp.exec_cmd("bemoji -t")'') ]; }

                  # toggle kb_layout
                  { _args = [ "ALT + Space" (mkLuaInline ''hl.dsp.exec_cmd("${./hypr/toggle_kb_layout.sh} ${cfg.keyboard}")'') ]; }

                  # toggle layout
                  { _args = [ "ALT + slash" (mkLuaInline ''hl.dsp.exec_cmd("${./hypr/toggle_layout.sh}")'') ]; }

                  { _args = [ "SUPER + Tab" (mkLuaInline "hl.dsp.focus({ last = true })") ]; }
                ]
              ];
        };

        submaps = {
          kill = {
            onDispatch = "reset";
            settings = { bind = [{ _args = [ "SUPER + q" (mkLuaInline "hl.dsp.window.close()") ]; }]; };
          };
        };
      };
    };
}
