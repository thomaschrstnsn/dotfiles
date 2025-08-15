{ config, lib, pkgs, ... }:

let
  tuigreet = "${pkgs.tuigreet}/bin/tuigreet";
  session = "${pkgs.hyprland}/bin/Hyprland";
  user = "thomas";
in
{
  boot = {
    loader.efi.canTouchEfiVariables = true;

    # Use the systemd-boot EFI boot loader.
    loader.systemd-boot.enable = true;

    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "udev.log_priority=3"
      "rd.systemd.show_status=auto"
      "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
    ];
  };

  programs.localsend.enable = true;

  services.xserver = {
    enable = true;
    xkb.layout = "gb";
  };
  services.libinput.enable = true;

  services.greetd = {
    enable = true;
    settings = {
      initial_session = {
        command = session;
        user = user;
      };
      default_session = {
        command = "${tuigreet} --greeting 'Welcome' --asterisks --remember --remember-user-session --time --cmd ${session}";
        user = "greeter";
      };
    };
  };

  services.seatd.enable = true;

  console = {
    keyMap = "uk";
    font = "ter-i20n";
    packages = with pkgs; [ terminus_font ];
    colors = [
      "16161D"
      "C34043"
      "76946A"
      "C0A36E"
      "7E9CD8"
      "957FB8"
      "6A9589"
      "C8C093"
      "727169"
      "E82424"
      "98BB6C"
      "E6C384"
      "7FB4CA"
      "938AA9"
      "7AA89F"
      "DCD7BA"
    ];
  };

  services.printing.enable = true;

  programs.hyprland.enable = true;
  # programs.hyprland.package = inputs.hyprland.packages."{$pkgs.system}".hyprland;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    powerManagement.enable = true;
  };

  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "thomas" ];
  };

  environment.etc = {
    "1password/custom_allowed_browsers" = {
      text = ''
        zen
      '';
      mode = "0755";
    };
  };

  environment.systemPackages = with pkgs; [
    mangohud
    protonup

    lutris
    heroic

    gparted
    ntfs3g
  ];

  environment.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
  };

  programs.gamemode.enable = true;

  services.dbus.enable = true;
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;

  security.rtkit.enable = true;
  security.polkit.enable = true;
  security.pam.services.hyprlock = { };

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

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    input = {
      General = {
        UserspaceHID = true;
      };
    };
  };

  services.blueman.enable = true;

  services.openssh.enable = true;

  services.kanata = {
    enable = false;
    keyboards.internal = {
      devices = [ "/dev/input/by-id/usb-Keychron_Keychron_Q11-event-kbd" ];
      config = builtins.readFile ./kanata.kbd;
      extraDefCfg = "process-unmapped-keys yes";
    };
  };

  security.pam.u2f = {
    enable = true;
    settings = {
      cue = true;
    };
  };

  security.pam.services = {
    login.u2fAuth = true;
    sudo.u2fAuth = true;
  };

  networking.hostName = "atlas"; # Define your hostname.

  time.hardwareClockInLocalTime = true;

  system.stateVersion = "24.05"; # Did you read the comment?
}

