{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.tc.sleepwatcher;

  dateCmd = ''date +"%Y-%m-%dT%H:%M:%S"'';
  logFile = "$HOME/sleep-wake.log";

  # Send all output (stdout + stderr) of the script to the log, and trace each
  # command so it is visible what ran even when it prints nothing.
  logPreamble = header: [
    ''exec >> "${logFile}" 2>&1''
    ''echo "${header} at $(${dateCmd})"''
    "set -x"
  ];

  sleeper = pkgs.writeShellApplication {
    name = "sleep-command";
    text = concatStringsSep "\n" (
      (logPreamble "Going to sleep")
      ++ optionals cfg.bluetooth.powerOffOnSleep [ ''${pkgs.blueutil}/bin/blueutil --power 0'' ]
      ++ (map (addr: ''${pkgs.blueutil}/bin/blueutil --disconnect ${addr}'') cfg.bluetooth.autoConnectDevices)
    );
  };
  waker = pkgs.writeShellApplication {
    name = "wake-command";
    text = concatStringsSep "\n" (
      (logPreamble "Waking up")
      ++ optionals cfg.bluetooth.powerOnOnWake [ ''${pkgs.blueutil}/bin/blueutil --power 1'' ]
      ++ (map (addr: ''${pkgs.blueutil}/bin/blueutil --connect ${addr}'') cfg.bluetooth.autoConnectDevices)
    );
  };
in
{
  options.tc.sleepwatcher = with types; {
    enable = mkEnableOption "sleepwatcher";

    bluetooth = {
      powerOffOnSleep = mkEnableOption "turn off bluetooth on sleep";
      powerOnOnWake = mkEnableOption "turn on bluetooth on wake";
      autoConnectDevices = mkOption {
        type = listOf str;
        description = "devices to automatically disconnect on sleep and reconnect on wake";
        example = [ "c8-bc-c8-fc-fe-fc" ];
        default = [ ];
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs;[ sleepwatcher sleeper ];

    launchd.user.agents.sleepwatcher = {
      serviceConfig = {
        ProgramArguments = [
          "${pkgs.sleepwatcher}/bin/sleepwatcher"
          "-s ${sleeper}/bin/sleep-command"
          "-w ${waker}/bin/wake-command"
        ];
        KeepAlive = true;
      };
    };
  };
}
