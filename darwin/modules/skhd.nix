{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.skhd;
  mkAppShortcut = (shortcut: app: "${shortcut} : open -a \"${app}\"");
  mkShortcut = (shortcut: cmd: "${shortcut} : ${cmd}");

  mkPrefixAppShortcut = (shortcut: app: "prefix < ${shortcut} : skhd -k escape ; open -a \"${app}\"");
  toPrefixConfig = config:
    if (config.leadingShortcut != null && config.appShortcuts != { })
    then
      concatStringsSep "\n"
        ([
          "# modal fun"
          (":: default" + (optionalString (config.commands.off != null) " : ${config.commands.off}"))
          (":: prefix " + (optionalString (config.commands.on != null) " : ${config.commands.on}"))
          "${config.leadingShortcut} ; prefix"
          "prefix < ${config.leadingShortcut} ; default"
          "prefix < escape ; default"
        ] ++ (attrValues (mapAttrs mkPrefixAppShortcut config.appShortcuts)))
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
    extraAppShortcuts = mkOption {
      description = "Extra shortcuts to open apps";
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
    prefixShortcuts.commands.on = mkOption {
      description = "command to signal prefix mode enabled";
      type = nullOr str;
      default = "sketchybar -m --set window label.highlight=on";
    };
    prefixShortcuts.commands.off = mkOption {
      description = "command to signal prefix mode disabled";
      type = nullOr str;
      default = "sketchybar -m --set window label.highlight=off";
    };
  };

  config = mkIf (cfg.enable) {
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
          hyper - a : yabai -m display --focus prev || yabai -m display --focus last
          hyper - s : yabai -m display --focus next || yabai -m display --focus first

          hyper - o : ${scripts}/moveWindowToSpaceOnSameDisplay.sh prev
          hyper - p : ${scripts}/moveWindowToSpaceOnSameDisplay.sh next
          hyper - tab : ${scripts}/moveWindowToFirstEmptySpaceOnSameDisplay.sh

          hyper - return : ${scripts}/toggleLayoutOnCurrentSpace.sh

          hyper - d : yabai -m space --toggle show-desktop
          hyper - e : yabai -m space --toggle mission-control

          hyper - 1 : ${scripts}/focusFirstWindowInSpace.sh 1
          hyper - 2 : ${scripts}/focusFirstWindowInSpace.sh 2
          hyper - 3 : ${scripts}/focusFirstWindowInSpace.sh 3
          hyper - 4 : ${scripts}/focusFirstWindowInSpace.sh 4
          hyper - 5 : ${scripts}/focusFirstWindowInSpace.sh 5
          hyper - 6 : ${scripts}/focusFirstWindowInSpace.sh 6
          hyper - 7 : ${scripts}/focusFirstWindowInSpace.sh 7
          hyper - 8 : ${scripts}/focusFirstWindowInSpace.sh 8

          hyper - j : yabai -m window --focus west
          hyper - l : yabai -m window --focus east
          hyper - i : yabai -m window --focus north
          hyper - k : yabai -m window --focus south

          hyper - m : yabai -m window --toggle native-fullscreen
          hyper - f : yabai -m window --toggle zoom-fullscreen

          hyper - left  : yabai -m window --resize left:-20:0; \
                          yabai -m window --resize right:-20:0;
          hyper - right : yabai -m window --resize right:20:0; \
                          yabai -m window --resize left:20:0;
          hyper - down  : yabai -m window --resize top:0:20; \
                          yabai -m window --resize bottom:0:20
          hyper - up    : yabai -m window --resize bottom:0:-20; \
                          yabai -m window --resize top:0:-20

          hyper - space : yabai -m space --rotate 270

          # app shortcuts
          hyper - b : open -a "${cfg.browser}"
          hyper - t : open -a "iTerm"
          hyper - x : open -a "Visual Studio Code"
        ''
        + concatStringsSep "\n" (attrValues (mapAttrs mkShortcut cfg.extraShortcuts))
        + "\n"
        + concatStringsSep "\n" (attrValues (mapAttrs mkAppShortcut cfg.extraAppShortcuts))
        + "\n"
        + toPrefixConfig cfg.prefixShortcuts
      ;
    };
  };
}
