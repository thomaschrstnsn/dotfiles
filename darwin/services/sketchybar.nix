{ config, lib, pkgs, ... }:

with lib;

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

  eventToSketchyBar = event: "${modify} --add event ${event}\n";

  spaceToSketchyBar = space:
    let
      header = "${modify} --add space ${space.name} ${space.position}";
      attrs = attrsToSetSketchyBar space.name space.attrs;
    in
    concatStringsSep " \\\n" (filter (s: s != "") [ header attrs ]) + "\n";

  itemToSketchyBar = item:
    let
      header = "${modify} --add item ${item.name} ${item.position}";
      script = optionalString (item.script != null) (''${tab}--set ${item.name} script="${item.script}'');
      subscribe = optionalString (item.subscribe != [ ]) (''${tab}--subscribe ${item.name} ${concatStringsSep " " item.subscribe}'');
      attrs = attrsToSetSketchyBar item.name item.attrs;
    in
    concatStringsSep " \\\n" (filter (s: s != "") [ header script subscribe attrs ]) + "\n";

  toSketchybarConfig = config:
    concatStringsSep "\n"
      (filter (s: s != "") (
        [
          (barToSketchyBar config.bar)
          (defaultToSketchyBar config.default)
        ]
        ++ (map spaceToSketchyBar config.spaces)
        ++ (map eventToSketchyBar config.events)
        ++ (map itemToSketchyBar config.items)
      ));

  configFile = mkIf (cfg.config != { } || cfg.extraConfig != "")
    "${pkgs.writeScript "sketchybarrc" (
      (if (cfg.config.items != [])
       then "${toSketchybarConfig cfg.config}"
       else "")
      + optionalString (cfg.extraConfig != "") cfg.extraConfig)}";
in
{
  options = with types; {
    services.sketchybar.enable = mkOption {
      type = bool;
      default = false;
      description = "Whether to enable the sketchybar";
    };

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
      type = listOf str;
      default = [ ];
      description = "external events to be defined";
    };

    services.sketchybar.config.items = mkOption {
      type = listOf (submodule {
        options = {
          name = mkOption {
            type = str;
            description = "Name of item";
          };
          position = mkOption {
            type = enum [ "left" "center" "right" ];
          };
          attrs = mkOption {
            type = attrs;
            default = { };
          };
          subscribe = mkOption {
            type = listOf str;
            default = [ ];
            description = "events subscribed to";
          };
          script = mkOption {
            type = nullOr path;
            default = null;
            description = "script to execute";
          };
        };
      });
      default = [ ];
      example = literalExpression ''
        [
          {
            name = "app_name";
            position = "left";
            attrs = {
              label.font = "heavyfont";
              label.color = "FF00FF";
            };
            script = "myscript.sh";
            subscribes = [ "title" "window_focus" ]
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

  config = mkIf (cfg.enable) {
    environment.systemPackages = [ cfg.package ];

    launchd.user.agents.sketchybar = {
      serviceConfig.ProgramArguments = [ "${cfg.package}/bin/sketchybar" ]
        ++ optionals (cfg.config != { } || cfg.extraConfig != "") [ "-c" configFile ];

      serviceConfig.KeepAlive = true;
      serviceConfig.RunAtLoad = true;
      serviceConfig.EnvironmentVariables = {
        PATH = "${cfg.package}/bin:${config.environment.systemPath}";
      };
    };
  };
}

