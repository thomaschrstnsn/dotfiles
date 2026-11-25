{ config, lib, ... }:

with lib;

let
  cfg = config.tc.laptop;
in
{
  options.tc.laptop = with types; {
    enable = mkEnableOption "laptop power handling (lid, upower, zram swap)";
  };

  config = mkIf cfg.enable {
    services.logind.settings.Login = {
      HandleLidSwitch = "suspend";
      HandleLidSwitchExternalPower = "suspend";
      HandleLidSwitchDocked = "ignore";
    };

    # battery information (e.g. for the noctalia battery widget)
    services.upower.enable = true;

    zramSwap = {
      enable = true;
      memoryPercent = 50;
    };
  };
}
