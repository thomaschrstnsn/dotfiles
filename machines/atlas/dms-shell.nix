{ config, lib, pkgs, ... }:

{
  programs.dms-shell = {
    enable = true;

    systemd = {
      enable = true; # Systemd service for auto-start
      restartIfChanged = true; # Auto-restart dms.service when dms-shell changes
    };

    plugins = {
      wallpaperDiscovery = {
        src = "${(pkgs.fetchFromGitHub {
          owner = "Lucyfire";
          repo = "dms-plugins";
          rev = "a3efd8147593fb21865ad9bd1183ea7cb0e1e701";
          hash = "sha256-SM7o076K2nC6y3bYyNvyDQczkanxt4eXbGx1K0ijHvo=";
        })}/wallpaperDiscovery";
      };
    };

    # Core features
    enableSystemMonitoring = true; # System monitoring widgets (dgop)
    enableVPN = false; # VPN management widget
    enableDynamicTheming = true; # Wallpaper-based theming (matugen)
    enableAudioWavelength = true; # Audio visualizer (cava)
    enableCalendarEvents = false; # Calendar integration (khal)
  };
}

