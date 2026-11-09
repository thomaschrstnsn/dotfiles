{ config, lib, ... }:

with lib;

let
  cfg = config.tc.kanata;
in
{
  options.tc.kanata = with types; {
    enable = mkEnableOption "kanata with macOS-like navigation keys";

    devices = mkOption {
      type = listOf str;
      description = "input devices (/dev/input/by-id/...) kanata should grab";
    };
  };

  config = mkIf cfg.enable {
    services.kanata = {
      enable = true;
      keyboards.internal = {
        inherit (cfg) devices;
        config = builtins.readFile ./kanata.kbd;
        extraDefCfg = "process-unmapped-keys yes";
      };
    };
  };
}
