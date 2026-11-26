{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.tc.sketchybar;

  # sketchybar sets $CONFIG_DIR to the directory of the rc file, which the
  # nix-darwin module writes straight into /nix/store; point it at the copied
  # config directory instead.
  configDir = ./sketchybar;
  nextMeetingApp = "${pkgs.myPkgs.nextMeeting}/Applications/NextMeeting.app";
in
{
  options.tc.sketchybar = with types; {
    enable = mkEnableOption "sketchybar status bar (bottom of the screen)";
    height = mkOption {
      type = int;
      default = 30;
      description = "bar height in pixels; aerospace's bottom gap follows it";
    };
  };

  config = mkIf cfg.enable {
    services.sketchybar = {
      enable = true;
      extraPackages = optionals config.tc.aerospace.enable [ config.services.aerospace.package ];
      config = ''
        #!/bin/bash
        export CONFIG_DIR=${configDir}
        export BAR_HEIGHT=${toString cfg.height}
        export NEXT_MEETING_APP=${nextMeetingApp}
        source "$CONFIG_DIR/sketchybarrc"
      '';
    };

    services.aerospace.settings = mkIf config.tc.aerospace.enable {
      gaps.outer.bottom = cfg.height + 4;
      exec-on-workspace-change = [
        "/bin/bash"
        "-c"
        "${config.services.sketchybar.package}/bin/sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE"
      ];
    };
  };
}
