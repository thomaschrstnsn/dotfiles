{ config, pkgs, lib, ... }:

{
  boot = {
    tmp.useTmpfs = true;
    kernelParams = [ "console=ttyS0,115200n8" "console=tty0" ];
  };

  boot.loader.raspberryPi.firmwareConfig = "dtparam=sd_poll_once=on";

  hardware = {
    enableRedistributableFirmware = true; # Required for the Wireless firmware
    bluetooth = {
      package = pkgs.bluez;
      enable = true;
      powerOnBoot = true;
    };
  };

  systemd.services = {
    # btattach = {
    #   before = [ "bluetooth.service" ];
    #   after = [ "dev-ttyAMA0.device" ];
    #   wantedBy = [ "multi-user.target" ];
    #   serviceConfig = {
    #     ExecStart = "${pkgs.bluez}/bin/btattach -B /dev/ttyAMA0 -P bcm -S 3000000";
    #   };
    # };
  };

  powerManagement.cpuFreqGovernor = "ondemand";

  networking.firewall.allowedTCPPorts = [ 8123 ];

  services.sshd.enable = true;

  services.cron.enable = true;

  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      dns = [ "192.168.1.1" ];
    };
  };

  environment.systemPackages = with pkgs; [
    vim
    docker-compose
    rclone
  ];

  environment.variables = {
    EDITOR = "vim";
  };

  nix = {
    settings.auto-optimise-store = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    # Free up to 1GiB whenever there is less than 100MiB left.
    extraOptions = ''
      min-free = ${toString (100 * 1024 * 1024)}
      max-free = ${toString (1024 * 1024 * 1024)}

      experimental-features = nix-command flakes
    '';
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  nixpkgs.config = {
    allowUnfree = true;
  };
  system.stateVersion = "20.09";
  swapDevices = [{ device = "/dev/disk/by-label/swap"; size = 4096; }];
}
