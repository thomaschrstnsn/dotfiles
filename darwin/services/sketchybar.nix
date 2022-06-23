{ config, lib, pkgs, ... }:

with lib;

# for debugging:
# ./build-darwin.sh && less $(grep sketchybarrc result/user/Library/LaunchAgents/org.nixos.sketchybar.plist | sed 's/<string>//' | sed 's|</string>|/sketchybar/sketchybarrc|' | awk '{print $1}')
let
  cfg = config.services.sketchybar;
  tab = "    ";
  modify = "sketchybar -m";

  attrsToSketchyBar = attrs:
    optionalString (attrs != { })
      (concatStringsSep
        " \\\n"
        (
          (mapAttrsToList (p: v: ''${tab}${tab}${p}="${toString v}"'') attrs)
        )
      );

  attrsToSetSketchyBar = name: attrs:
    optionalString (attrs != { })
      (concatStringsSep
        " \\\n"
        (
          [ "${tab}--set ${name}" ] ++
          (mapAttrsToList (p: v: ''${tab}${tab}${p}="${toString v}"'') attrs)
        )
      );

  barToSketchyBar = bar:
    let
      header = "${modify} --bar";
      attrs = attrsToSketchyBar bar;
    in
    optionalString (attrs != "") concatStringsSep " \\\n" (filter (s: s != "") [ header attrs ]) + "\n";

  defaultToSketchyBar = defaults:
    let
      header = "${modify} --default";
      attrs = attrsToSketchyBar defaults;
    in
    optionalString (attrs != "") (concatStringsSep " \\\n" (filter (s: s != "") [ header attrs ])) + "\n";

  eventToSketchyBar = event: "${modify} --add event ${event.name} ${optionalString (event.notificationCenterEvent != null) event.notificationCenterEvent}\n";

  spaceToSketchyBar = space:
    let
      header = "${modify} --add space ${space.name} ${space.position}";
      attrs = attrsToSetSketchyBar space.name space.attrs;
    in
    concatStringsSep " \\\n" (filter (s: s != "") [ header attrs ]) + "\n";

  itemToSketchyBar = bracketName: item:
    let
      mkPosition = position:
        if (builtins.typeOf position == "string") # string = enum?
        then
          if (item.graphWidth != null)
          then
            "${position} ${toString item.graphWidth}"
          else
            "${position}"
        else
          if (builtins.typeOf position == "set")
          then "popup.${position.popup}"
          else abort "position: '${builtins.typeOf position}' not a str or a popup (should not be possible)";
      name =
        if (bracketName == "")
        then
          item.name
        else
          "${bracketName}.${item.name}";
      header = "${modify} --add ${item.itemType} ${name} ${mkPosition item.position}";
      script = optionalString (item.script != null) (''${tab}--set ${name} script="${item.script}'');
      subscribe = optionalString (item.subscribe != [ ]) (''${tab}--subscribe ${name} ${concatStringsSep " " item.subscribe}'');
      attrs = attrsToSetSketchyBar name item.attrs;
    in
    concatStringsSep " \\\n" (filter (s: s != "") [ header script subscribe attrs ]) + "\n";

  addBracket = bracket:
    let
      name = bracket.bracket;
      header = "${modify} --add bracket ${name}";
      items = concatStringsSep " " (map (item: "${name}.${item.name}") bracket.items);
      #attrs = attrsToSetSketchyBar name item.attrs;
    in
    concatStringsSep " " [ header items ] + "\n";

  bracketToSketchyBar = bracket:
    if (bracket.bracket == "")
    then
      if (length bracket.items == 1)
      then
        (concatStringsSep "\n" (map (itemToSketchyBar "") bracket.items)) + "\n"
      else
        builtins.throw "empty named brackets only supported for 'single-item' brackets"
    else
      (concatStringsSep "\n"
        ([ ]
        ++ (map (itemToSketchyBar bracket.bracket) bracket.items)
        ++ [ "" ]
        )) + (addBracket bracket);

  toSketchybarConfig = config:
    concatStringsSep "\n"
      (filter (s: s != "") (
        [
          (barToSketchyBar config.bar)
          (defaultToSketchyBar config.default)
        ]
        ++ (map spaceToSketchyBar config.spaces)
        ++ (map eventToSketchyBar config.events)
        ++ (map bracketToSketchyBar config.items)
      ));

  configFile =
    (if (cfg.config.items != [ ])
    then "${toSketchybarConfig cfg.config}"
    else "")
    + optionalString (cfg.extraConfig != "") cfg.extraConfig;

  configHome = pkgs.writeTextFile {
    name = "sketchybarrc";
    text = configFile;
    destination = "/sketchybar/sketchybarrc";
    executable = true;
  };
in
{
  options = with types;
    let
      item = submodule {
        options = {
          name = mkOption {
            type = str;
            description = "Name of item";
          };
          position = mkOption {
            type = oneOf [
              (enum [ "left" "center" "right" ])
              (submodule {
                options = {
                  type = enum [ "popup" ];
                  popup = mkOption {
                    type = str;
                    description = "which item to be a popup on";
                  };
                };
              })
            ];
          };
          itemType = mkOption {
            type = enum [ "item" "graph" "alias" ];
            default = "item";
          };
          graphWidth = mkOption {
            type = nullOr int;
            default = null;
            description = "width (when a graph)";
          };
          attrs = mkOption
            {
              type = attrs;
              default = { };
            };
          subscribe = mkOption
            {
              type = listOf str;
              default = [ ];
              description = "events subscribed to";
            };
          script = mkOption
            {
              type = nullOr path;
              default = null;
              description = "script to execute";
            };
        };
      };
      bracket = submodule
        {
          options = {
            bracket = mkOption {
              type = str;
              description = "name of bracket";
            };
            items = mkOption {
              type = nonEmptyListOf item;
            };
          };
        };
    in
    {
      services.sketchybar.enable = mkEnableOption "sketchybar";

      services.sketchybar.package = mkOption {
        type = path;
        description = "The sketchybar package to use.";
      };

      services.sketchybar.config.bar = mkOption {
        type = attrs;
        default = { };
        description = "bar's visual attributes";
      };

      services.sketchybar.config.default = mkOption {
        type = attrs;
        default = { };
        description = "item defaults";
      };

      services.sketchybar.config.spaces = mkOption {
        type = listOf (submodule {
          options = {
            name = mkOption {
              type = str;
            };
            position = mkOption {
              type = enum [ "left" "center" "right" ];
            };
            attrs = mkOption {
              type = attrs;
            };
          };
        });
      };

      services.sketchybar.config.events = mkOption {
        type = listOf (submodule {
          options = {
            name = mkOption {
              type = str;
              description = "Name of event";
            };
            notificationCenterEvent = mkOption {
              type = nullOr str;
              default = null;
              description = "NSDistributedNotificationCenter event to hook into";
              example = "com.apple.bluetooth.state";
            };
          };
        });
        default = [ ];
        description = "external events to be defined";
      };

      # ideally this would be typed as `listOf (oneOf [bracket item])` but that is not possible
      services.sketchybar.config.items = mkOption {
        type = listOf bracket;
        default = [ ];
        example = literalExpression ''
          [ 
            # items in bracket be prefixed with bracket name, e.g. "bracket1.app_name"
            { 
              name = "bracket1";
              items = [
                {
                  name = "app_name";
                  position = "left";
                  attrs = {
                    label.font = "heavyfont";
                    label.color = "FF00FF";
                  };
                  script = "myscript.sh";
                  subscribe = [ "title" "window_focus" ];
                }
              ];
            }
            # special handling of 'single-item' bracket, no prefixing occurs.
            # requires: 1 item and empty name
            {
              name = "";
              items = [
                {
                  name = "app_name";
                  position = "left";
                  attrs = {
                    label.font = "heavyfont";
                    label.color = "FF00FF";
                  };
                  script = "myscript.sh";
                  subscribe = [ "title" "window_focus" ];
                }
              ];
            }
          ]
        '';
        description = "items";
      };

      services.sketchybar.extraConfig = mkOption {
        type = str;
        default = "";
        example = literalExpression ''
          echo "sketchybar config loaded..."
        '';
        description = ''
          Extra arbitrary configuration to append to the configuration file.
        '';
      };
    };

  config = mkIf
    (cfg.enable)
    {
      environment.systemPackages = [ cfg.package ];

      launchd.user.agents.sketchybar = {
        serviceConfig.ProgramArguments = [ "${cfg.package}/bin/sketchybar" ];

        serviceConfig.KeepAlive = true;
        serviceConfig.RunAtLoad = true;
        serviceConfig.EnvironmentVariables = {
          PATH = "${cfg.package}/bin:${config.environment.systemPath}";
          XDG_CONFIG_HOME = mkIf (cfg.config != "") "${configHome}";
        };
      };
    };
}



