{ config, lib, pkgs, ... }:

{
  # Use the systemd-boot EFI boot loader.
  # boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader = {
    grub = {
      enable = true;
      devices = [ "nodev" ];
      efiSupport = true;
      useOSProber = true;
    };
  };

  services.xserver = {
    enable = true;
    xkb.layout = "gb";
  };
  services.libinput.enable = true;

  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd hyprland";
      user = "greeter";
    };
  };

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
  };

  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;

  environment.systemPackages = with pkgs; [
    mangohud
    protonup
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
  hardware.pulseaudio.enable = false;

  security.rtkit.enable = true;
  security.polkit.enable = true;
  security.pam.services.hyprlock = { };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  services.openssh.enable = true;

  services.kanata = {
    enable = true;
    keyboards.internal = {
      devices = [ "/dev/input/by-id/usb-Keychron_Keychron_Q11-event-kbd" ];
      config = builtins.readFile ./kanata.kbd;
      extraDefCfg = "process-unmapped-keys yes";
    };
  };

  networking.hostName = "atlas"; # Define your hostname.

  time.hardwareClockInLocalTime = true;

  system.stateVersion = "24.05"; # Did you read the comment?
}

