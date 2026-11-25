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

  # star citizen
  nix.settings = {
    substituters = [ "https://nix-citizen.cachix.org" ];
    trusted-public-keys = [ "nix-citizen.cachix.org-1:lPMkWc2X8XD4/7YPEEwXKKBg+SVbYTVrAaLA2wQTKCo=" ];
  };

  programs.localsend.enable = true;

  services.xserver = {
    xkb.layout = "gb";
  };
  services.libinput.enable = true;

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

  hardware.graphics.enable32Bit = true;

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    open = true;
    nvidiaSettings = true;
    # package = config.boot.kernelPackages.nvidiaPackages.latest;
    package = pkgs.linuxPackages.nvidiaPackages.legacy_580;
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
        .zen-beta-wrapped
      '';
      mode = "0755";
    };
  };

  environment.systemPackages = with pkgs; [
    mangohud
    protonplus

    lutris
    heroic

    usbutils

    gparted
    ntfs3g

    proton-vpn
  ];

  environment.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
  };

  programs.gamemode.enable = true;

  hardware.enableRedistributableFirmware = true;

  hardware.bluetooth.input = {
    General = {
      UserspaceHID = true;
    };
  };

  services.openssh.enable = true;

  # Proton VPN: the official app manages its connections through NetworkManager
  networking.networkmanager.enable = true;
  # WireGuard traffic fails the strict reverse path check
  networking.firewall.checkReversePath = "loose";
  # Proton VPN stores its session in the Secret Service keyring (enabled by tc.hyprland)

  tc.kanata = {
    enable = true;
    devices = [ "/dev/input/by-id/usb-Keychron_Keychron_Q11-event-kbd" ];
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

  programs.yubikey-touch-detector = {
    enable = true;
    libnotify = true;
  };

  system.stateVersion = "24.05"; # Did you read the comment?
}

