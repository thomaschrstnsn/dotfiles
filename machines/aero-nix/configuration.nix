{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    efi.efiSysMountPoint = "/boot/efi";
    systemd-boot.configurationLimit = 10;
  };

  # broadcom_sta (wl) is the only working driver for the BCM4360 wifi, but is
  # marked insecure in nixpkgs. (A predicate, since the flake sets
  # permittedInsecurePackages and nixpkgs.config lists do not merge.)
  nixpkgs.config.allowInsecurePredicate = pkg: lib.getName pkg == "broadcom-sta";

  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Copenhagen";

  i18n.defaultLocale = "en_DK.UTF-8";

  services.xserver.xkb.layout = "gb";
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

  # Haswell (Intel HD 5000) video acceleration
  hardware.graphics.extraPackages = with pkgs; [ intel-vaapi-driver ];

  hardware.enableRedistributableFirmware = true;

  services.printing.enable = true;

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

  services.openssh.enable = true;

  tc.kanata = {
    enable = true;
    devices = [ "/dev/input/by-id/usb-Apple_Inc._Apple_Internal_Keyboard___Trackpad_DQ63223LKPCF94RAGBD-if01-event-kbd" ];
  };

  system.stateVersion = "22.05"; # Did you read the comment?
}
