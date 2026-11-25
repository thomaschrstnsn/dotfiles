# Keybindings and submaps.
{ pkgs, config, lib, ... }:
with lib; with builtins;

let
  mkLuaInline = generators.mkLuaInline;

  mkIfList = cond: xs: if cond then xs else [ ];

  cfg = config.tc.hyprland;

  inherit (import ./commands.nix { inherit pkgs cfg; })
    clipseClass lockCmd launcherCmd screenshotCmd terminal;

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

  clipboardCmd = {
    clipse = "${terminal.starter cfg.terminal {class = clipseClass; command = "clipse";}}";
    noctalia = "noctalia msg panel-toggle clipboard";
  }."${cfg.clipboard}";

  # bind that works on the lockscreen and repeats while held
  repeatingBind = key: cmd: {
    _args = [ key (mkLuaInline ''hl.dsp.exec_cmd("${cmd}")'') { locked = true; repeating = true; } ];
  };
in
{
  config = mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      settings.bind = concatLists
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
            { _args = [ "SUPER + Space" (mkLuaInline ''hl.dsp.exec_cmd("${launcherCmd}")'') ]; }
            { _args = [ (mkLuaInline ''hyper .. " + f"'') (mkLuaInline "hl.dsp.window.fullscreen()") ]; }
            { _args = [ "SHIFT + SUPER + f" (mkLuaInline "hl.dsp.window.float()") ]; }
            { _args = [ "SHIFT + SUPER + 4" (mkLuaInline ''hl.dsp.exec_cmd("${screenshotCmd}")'') ]; }
            { _args = [ "CTRL + SUPER + q" (mkLuaInline ''hl.dsp.exec_cmd("${lockCmd}")'') ]; }
          ]
          (mkIfList (cfg.shell == "hyprpanel") [
            { _args = [ "CTRL + Escape" (mkLuaInline ''hl.dsp.exec_cmd("${pkgs.hyprpanel}/bin/hyprpanel t verification")'') ]; }
            { _args = [ "CTRL + SHIFT + Escape" (mkLuaInline ''hl.dsp.exec_cmd("${pkgs.hyprpanel}/bin/hyprpanel t powerdropdownmenu")'') ]; }
          ])
          (mkIfList (cfg.shell == "noctalia") [
            { _args = [ "CTRL + Escape" (mkLuaInline ''hl.dsp.exec_cmd("noctalia msg panel-toggle session")'') ]; }
          ])
          # mediakeys
          [
            { _args = [ "XF86AudioRaiseVolume" (mkLuaInline ''hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ +10%")'') ]; }
            { _args = [ "XF86AudioLowerVolume" (mkLuaInline ''hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ -10%")'') ]; }
            { _args = [ "XF86AudioMute" (mkLuaInline ''hl.dsp.exec_cmd("pactl set-sink-mute @DEFAULT_SINK@ toggle")'') ]; }
            { _args = [ "XF86AudioMicMute" (mkLuaInline ''hl.dsp.exec_cmd("pactl set-source-mute @DEFAULT_SOURCE@ toggle")'') ]; }
          ]
          (mkIfList cfg.laptop.brightnessKeys [
            (repeatingBind "XF86MonBrightnessUp" "brightnessctl set 5%+")
            (repeatingBind "XF86MonBrightnessDown" "brightnessctl set 5%-")
            (repeatingBind "XF86KbdBrightnessUp" "brightnessctl --device=smc::kbd_backlight set 10%+")
            (repeatingBind "XF86KbdBrightnessDown" "brightnessctl --device=smc::kbd_backlight set 10%-")
          ])
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
            { _args = [ (mkLuaInline ''hyper .. " + b"'') (mkLuaInline ''hl.dsp.exec_cmd("${pkgs.myPkgs.hyprfocus}/bin/hyprfocus initial-title \"Zen Browser\" start zen-beta")'') ]; }
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
            { _args = [ "SUPER + C" (mkLuaInline ''hl.dsp.exec_cmd("${./hypr/send_unless_term.sh} CTRL C CTRL+SHIFT")'') ]; }
            { _args = [ "SUPER + V" (mkLuaInline ''hl.dsp.exec_cmd("${./hypr/send_unless_term.sh} CTRL V CTRL+SHIFT")'') ]; }
            { _args = [ "SUPER + X" (mkLuaInline ''hl.dsp.exec_cmd("${./hypr/send_unless_term.sh} CTRL X")'') ]; }
            { _args = [ "SUPER + A" (mkLuaInline ''hl.dsp.exec_cmd("${./hypr/send_unless_term.sh} CTRL A")'') ]; }
            { _args = [ "SUPER + Z" (mkLuaInline ''hl.dsp.exec_cmd("${./hypr/send_unless_term.sh} CTRL Z")'') ]; }
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

      submaps = {
        kill = {
          onDispatch = "reset";
          settings = { bind = [{ _args = [ "SUPER + q" (mkLuaInline "hl.dsp.window.close()") ]; }]; };
        };
      };
    };
  };
}
