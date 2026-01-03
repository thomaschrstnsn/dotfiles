{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.skhd;

  switchToApp = onlySwitchIfOpen: app: ''${pkgs.myPkgs.aeroTrafficControl}/bin/aero-traffic-control ${if onlySwitchIfOpen then "--no-open" else ""} "${app}"'';
  mkAppShortcut = onlySwitchIfOpen: shortcut: app: "${shortcut} : ${switchToApp onlySwitchIfOpen app}";
  mkShortcut = shortcut: cmd: "${shortcut} : ${cmd}";

  mkPrefixShortcut = (prefix: shortcut: command: "${prefix} < ${shortcut} : ${command}");

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
          lctrl - up   : skhd -k "pageup"
          lctrl - down : skhd -k "pagedown"

          f13 : osascript ${scripts}/toggle-mute-mic.applescript

          # app shortcuts
          hyper - b : ${(switchToApp false) cfg.browser}
          hyper - t : ${(switchToApp false) cfg.terminal}
          hyper - x : ${(switchToApp false) "Finder"}
        ''
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

