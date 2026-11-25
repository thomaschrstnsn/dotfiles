{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.tc.hyprland;
  user = config.tc.user.name;

  tuigreet = "${pkgs.tuigreet}/bin/tuigreet";
  session = "${pkgs.hyprland}/bin/start-hyprland";

  # the lockscreen is chosen in the home-manager tc.hyprland module
  hmHyprland = attrByPath [ "home-manager" "users" user "tc" "hyprland" ] null config;
  useHyprlock = hmHyprland != null && hmHyprland.enable && hmHyprland.lockscreen == "hyprlock";
in
{
  options.tc.hyprland = with types; {
    enable = mkEnableOption "hyprland desktop session (greetd, portals, polkit, pipewire, keyring)";

    autologin = mkEnableOption ''
      logging in the user automatically on boot (the hyprland session locks
      the screen on start)
    '';

    bluetooth.enable = mkEnableOption "bluetooth with blueman";
  };

  config = mkIf cfg.enable {
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${tuigreet} --greeting 'Welcome' --asterisks --remember --remember-user-session --time --cmd ${session}";
          user = "greeter";
        };
      } // optionalAttrs cfg.autologin {
        initial_session = {
          command = session;
          inherit user;
        };
      };
    };

    services.seatd.enable = true;

    programs.hyprland.enable = true;

    hardware.graphics.enable = true;

    services.dbus.enable = true;
    xdg.portal = {
      enable = true;
      wlr.enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };

    # Enable sound with pipewire.
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    security.polkit.enable = true;
    security.pam.services.hyprlock = mkIf useHyprlock { };

    systemd = {
      user.services.polkit-gnome-authentication-agent-1 = {
        description = "polkit-gnome-authentication-agent-1";
        wantedBy = [ "graphical-session.target" ];
        wants = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
      };
    };

    # Secret Service keyring (used by e.g. Proton VPN, browsers)
    services.gnome.gnome-keyring.enable = true;
    security.pam.services.greetd.enableGnomeKeyring = true;

    hardware.bluetooth = mkIf cfg.bluetooth.enable {
      enable = true;
      powerOnBoot = true;
    };
    services.blueman.enable = mkIf cfg.bluetooth.enable true;
  };
}
