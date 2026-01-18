{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.tc.sleepwatcher;

  dateCmd = ''date +"%Y-%m-%dT%H:%M:%S"'';

  sleeper = pkgs.writeShellApplication {
    name = "sleep-command";
    runtimeInputs = optionals cfg.bluetooth [ pkgs.blueutil ];
    text = ''
      echo "Going to sleep at $(${dateCmd})" >> ~/sleep-wake.log
    '' + (if cfg.bluetooth
    then ''
      ${pkgs.blueutil}/bin/blueutil --power 0
    ''
    else "");
  };
  waker = pkgs.writeShellApplication {
    name = "wake-command";
    runtimeInputs = optionals cfg.bluetooth [ pkgs.blueutil ];
    text = ''
      echo "Waking up at $(${dateCmd})" >> ~/sleep-wake.log
    '' + (if cfg.bluetooth
    then ''
      ${pkgs.blueutil}/bin/blueutil --power 1
    ''
    else "");
  };
in
{
  options.tc.sleepwatcher = {
    enable = mkEnableOption "sleepwatcher";

    bluetooth = mkEnableOption "turn off/on bluetooth on sleep/wake";
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
