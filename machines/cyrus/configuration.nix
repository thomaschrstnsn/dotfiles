{ config, lib, pkgs, ... }:

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

  services.libinput.enable = true;

  # gnome
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # flatpak
  services.flatpak.enable = true;

  # Set system locale to Danish
  i18n.defaultLocale = "da_DK.UTF-8";

  # Optional: Set additional locale settings
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "da_DK.UTF-8";
    LC_IDENTIFICATION = "da_DK.UTF-8";
    LC_MEASUREMENT = "da_DK.UTF-8";
    LC_MONETARY = "da_DK.UTF-8";
    LC_NAME = "da_DK.UTF-8";
    LC_NUMERIC = "da_DK.UTF-8";
    LC_PAPER = "da_DK.UTF-8";
    LC_TELEPHONE = "da_DK.UTF-8";
    LC_TIME = "da_DK.UTF-8";
  };

  # Set X11 keyboard layout to Danish
  services.xserver.xkb = {
    layout = "dk";
    variant = "";
  };

  # system tray icons
  services.udev.packages = [ pkgs.gnome-settings-daemon ];

  # user
  users.users.conrad = {
    isNormalUser = true;
    hashedPassword = "$y$j9T$47awgiyRva9pe9jJwkutb/$MdXYNh0PrdHqwC6nzHCHVHuwwt.WCsOsMaHtxR7ySfD";
    extraGroups = [ "gamemode" ];
  };

  services.seatd.enable = true;

  console = {
    # Configure console for Danish keyboard
    keyMap = "dk";
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
    polkitPolicyOwners = [ "conrad" ];
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
    protonup-ng

    lutris
    heroic
    lunar-client

    usbutils

    gparted
    ntfs3g

    gnomeExtensions.appindicator
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

  services.timekpr = {
    enable = true;
    adminUsers = [ "thomas" "tkcol" ];
  };

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;

  security.rtkit.enable = true;
  security.polkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  services.openssh.enable = true;

  system.stateVersion = "24.05"; # Did you read the comment?
}

