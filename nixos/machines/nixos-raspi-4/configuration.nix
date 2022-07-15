{ config, pkgs, lib, ... }:

{
  boot = {
    tmpOnTmpfs = true;
    # ttyAMA0 is the serial console broken out to the GPIO
    kernelParams = [
      "8250.nr_uarts=1"
      "console=ttyAMA0,115200"
      "console=tty1"
      # Some gui programs need this
      "cma=128M"
    ];
  };

  boot.loader.raspberryPi.firmwareConfig = "dtparam=sd_poll_once=on";

  hardware = {
    enableRedistributableFirmware = true; # Required for the Wireless firmware
    bluetooth.enable = true;
  };

  powerManagement.cpuFreqGovernor = "ondemand";

  networking.firewall.allowedTCPPorts = [ 8123 ];

  services.sshd.enable = true;

  services.cron.enable = true;

  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [
    vim
    docker-compose
    rclone
  ];

  environment.variables = {
    EDITOR = "vim";
  };

  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    interactiveShellInit = ''
      source ${pkgs.grml-zsh-config}/etc/zsh/zshrc
    '';
    promptInit = ""; # otherwise it'll override the grml prompt
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

  # Assuming this is installed on top of the disk image.
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  nixpkgs.config = {
    allowUnfree = true;
  };
  system.stateVersion = "20.09";
  #swapDevices = [ { device = "/swapfile"; size = 3072; } ];
}
