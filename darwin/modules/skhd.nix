{ pkgs, config, lib, ... }:
with lib;

let
  # keyed by the app name (file in /Applications sans the .app) and contains the app name on windows
  windowNames = {
    "Visual Studio Code" = "Code";
    "iTerm" = "iTerm2";
  };

  windowNameForApp = app:
    if hasAttr app windowNames
    then getAttr app windowNames
    else app;

  cfg = config.tc.skhd;
  switchToApp = onlySwitchIfOpen: app:
    if cfg.useOpenForAppShortcuts
    then ''open -a "${app}"''
    else ''${scripts}/switchToApp.sh "${windowNameForApp app}" "${if onlySwitchIfOpen then "" else app}"'';
  mkAppShortcut = (onlySwitchIfOpen: shortcut: app: "${shortcut} : ${switchToApp onlySwitchIfOpen app}");
  mkShortcut = (shortcut: cmd: "${shortcut} : ${cmd}");

  mkPrefixShortcut = (prefix: shortcut: command: "${prefix} < ${shortcut} : ${command}");

  toWmPrefixConfig = wmPrefixShortcut: shortcuts:
    concatStringsSep "\n"
      ([
        "# wmprefix"
        (":: default" + (optionalString (cfg.prefixShortcuts.commands.off != null) " : ${cfg.prefixShortcuts.commands.off}"))
        (":: wmprefix " + (optionalString (cfg.prefixShortcuts.commands.on != null) " : ${cfg.prefixShortcuts.commands.on}"))
        "${wmPrefixShortcut} ; wmprefix"
        "wmprefix < ${wmPrefixShortcut} ; default"
        "wmprefix < escape ; default"
      ] ++ (attrValues (mapAttrs (mkPrefixShortcut "wmprefix") shortcuts))
      ++ [ "" ]
      );

  mkCfgPrefixAppShortcut = (shortcut: app: (mkPrefixShortcut "cfgprefix" shortcut "skhd -k escape ; ${switchToApp false app}"));
  mkCfgPrefixShortcut = (shortcut: command: (mkPrefixShortcut "cfgprefix" shortcut "skhd -k escape ; ${command}"));
  toCfgPrefixConfig = config:
    if (config.leadingShortcut != null && (config.appShortcuts != { } || config.shortcuts != { }))
    then
      concatStringsSep "\n"
        ([
          "# cfgprefix"
          (":: cfgprefix " + (optionalString (config.commands.on != null) " : ${config.commands.on}"))
          "${config.leadingShortcut} ; cfgprefix"
          "cfgprefix < ${config.leadingShortcut} ; default"
          "cfgprefix < escape ; default"
        ]
        ++ (attrValues (mapAttrs mkCfgPrefixAppShortcut config.appShortcuts))
        ++ (attrValues (mapAttrs mkCfgPrefixShortcut config.shortcuts))
        ++ [ "" ]
        )
    else "";

  scripts = ./skhd;

  resize = rec {
    pixels = "50";
    left = "yabai -m window --resize left:-${pixels}:0; yabai -m window --resize right:-${pixels}:0";
    right = "yabai -m window --resize right:${pixels}:0; yabai -m window --resize left:${pixels}:0;";
    down = "yabai -m window --resize top:0:${pixels}; yabai -m window --resize bottom:0:${pixels}";
    up = "yabai -m window --resize bottom:0:-${pixels}; yabai -m window --resize top:0:-${pixels}";
  };
in
{
  options.tc.skhd = with types; {
    enable = mkEnableOption "simple hotkey deamon";
    browser = mkOption {
      description = "Which app to use as browser shortcut";
      type = str;
      default = "Safari";
    };
    terminal = mkOption {
      description = "Which app to use as terminal shortcut";
      type = str;
      default = "iTerm";
    };
    code = mkOption {
      description = "Which app to use for the code shortcut";
      type = str;
      default = "Visual Studio Code";
    };
    useOpenForAppShortcuts = mkOption {
      type = bool;
      description = "Use 'open -a' to open apps (otherwise use custom switchToApp script)";
      default = true;
    };
    extraAppShortcuts = mkOption {
      description = "Extra shortcuts to open apps";
      type = attrsOf str;
      default = { };
      example = {
        "hyper - z" = "zoom.us";
      };
    };
    extraAppShortcutsOnlySwitch = mkOption {
      description = "Extra shortcuts to only switch to apps (not open them of they are not running)";
      type = attrsOf str;
      default = { };
      example = {
        "hyper - z" = "zoom.us";
      };
    };
    extraShortcuts = mkOption {
      description = "Extra shortcuts";
      type = attrsOf str;
      default = { };
      example = {
        "ctrl - space" = "open-iterm.sh launcher";
      };
    };
    prefixShortcuts.leadingShortcut = mkOption {
      description = "prefix shortcuts' leading key";
      type = nullOr str;
      default = null;
      example = "hyper - 9";
    };
    prefixShortcuts.appShortcuts = mkOption {
      description = "shortcuts after prefix leading combination";
      type = attrsOf str;
      default = { };
      example = {
        d = "Microsoft Remote Desktop";
      };
    };
    prefixShortcuts.shortcuts = mkOption {
      description = "non-app shortcuts after prefix leading combination";
      type = attrsOf str;
      default = { };
      example = {
        d = "yabai -m space --toggle show-desktop";
      };
    };
    prefixShortcuts.commands.on = mkOption {
      description = "command to signal prefix mode enabled";
      type = nullOr str;
      default = "sketchybar -m --set window background.drawing=on";
    };
    prefixShortcuts.commands.off = mkOption {
      description = "command to signal prefix mode disabled";
      type = nullOr str;
      default = "sketchybar -m --set window background.drawing=off";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      jq
      skhd
    ];

    launchd.user.agents.skhd.serviceConfig = {
      StandardErrorPath = "/tmp/skhd.log";
      StandardOutPath = "/tmp/skhd.log";
    };

    services.skhd = {
      enable = true;
      # https://github.com/koekeishiya/skhd/issues/1
      skhdConfig =
        ''
          hyper - q : ${scripts}/moveWindowToDisplayAndFollowFocus.sh left
          hyper - w : ${scripts}/moveWindowToDisplayAndFollowFocus.sh right
          # hyper - a : yabai -m display --focus prev || yabai -m display --focus last
          # hyper - s : yabai -m display --focus next || yabai -m display --focus first

          hyper - o : ${scripts}/moveWindowToSpaceOnSameDisplay.sh prev
          hyper - p : ${scripts}/moveWindowToSpaceOnSameDisplay.sh next
          hyper - tab : ${scripts}/moveWindowToFirstEmptySpaceOnSameDisplay.sh

          cmd - 0x32 : ${scripts}/cycleApp.sh

          hyper - return : ${scripts}/toggleLayoutOnCurrentSpace.sh

          hyper - 0x0A : yabai -m space --toggle show-desktop # button left of 1
          hyper - e : yabai -m space --toggle mission-control

          hyper - 1 : ${scripts}/focusFirstWindowInSpace.sh 1
          hyper - 2 : ${scripts}/focusFirstWindowInSpace.sh 2
          hyper - 3 : ${scripts}/focusFirstWindowInSpace.sh 3
          hyper - 4 : ${scripts}/focusFirstWindowInSpace.sh 4
          hyper - 5 : ${scripts}/focusFirstWindowInSpace.sh 5
          hyper - 6 : ${scripts}/focusFirstWindowInSpace.sh 6
          hyper - 7 : ${scripts}/focusFirstWindowInSpace.sh 7
          hyper - 8 : ${scripts}/focusFirstWindowInSpace.sh 8

          hyper - h : yabai -m window --focus west
          hyper - l : yabai -m window --focus east
          hyper - j : yabai -m window --focus north
          hyper - k : yabai -m window --focus south

          hyper - m : yabai -m window --toggle native-fullscreen
          hyper - f : yabai -m window --toggle zoom-fullscreen

          hyper - left  : ${resize.left}
          hyper - right : ${resize.right}
          hyper - down  : ${resize.down}
          hyper - up    : ${resize.up}

          lctrl - up   : skhd -k "pageup"
          lctrl - down : skhd -k "pagedown"

          # app shortcuts
          hyper - b : ${(switchToApp false) cfg.browser}
          hyper - t : ${(switchToApp false) cfg.terminal}
          hyper - x : ${(switchToApp false) "Finder"}
        ''
        + (toWmPrefixConfig "hyper - space" {
          f = "yabai -m window --toggle float; yabai -m window --grid 4:4:1:1:2:2"; # float/unfloat
          q = "yabai -m space --rotate 90";
          w = "yabai -m space --rotate 270";
          s = "yabai -m window --toggle split";

          h = "yabai -m window --focus west";
          l = "yabai -m window --focus east";
          j = "yabai -m window --focus north";
          k = "yabai -m window --focus south";

          "shift - h" = "yabai -m window --swap west";
          "shift - l" = "yabai -m window --swap east";
          "shift - j" = "yabai -m window --swap north";
          "shift - k" = "yabai -m window --swap south";

          n = "${scripts}/yabaiCycleCounterClockwise.sh";
          m = "${scripts}/yabaiCycleClockwise.sh";

          up = "yabai -m window --warp north";
          down = "yabai -m window --warp south";
          left = "yabai -m window --warp west";
          right = "yabai -m window --warp east";

          "shift - left" = resize.left;
          "shift - right" = resize.right;
          "shift - down" = resize.down;
          "shift - up" = resize.up;
        })
        + concatStringsSep "\n" (attrValues (mapAttrs mkShortcut cfg.extraShortcuts))
        + "\n"
        + concatStringsSep "\n" (attrValues (mapAttrs (mkAppShortcut false) cfg.extraAppShortcuts))
        + "\n"
        + concatStringsSep "\n" (attrValues (mapAttrs (mkAppShortcut true) cfg.extraAppShortcutsOnlySwitch))
        + "\n"
        + toCfgPrefixConfig cfg.prefixShortcuts
      ;
    };
  };
}

