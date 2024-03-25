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

  systemd = {
    # systemctl list-timers
    timers = {
      tmbackup = {
        wantedBy = [ "multi-user.target" ];
        timerConfig = {
          Unit = "tmbackup.service";
          OnCalendar = "*-*-* 3:00:00";
        };
      };
      habackup = {
        wantedBy = [ "multi-user.target" ];
        timerConfig = {
          Unit = "habackup.service";
          OnCalendar = "*-*-* 4:00:00";
        };
      };
    };
    # manually start: systemctl start tmbackup
    # status: systemctl status tmbackup
    services = {
      # inspiration https://www.teslaev.co.uk/how-to-perform-an-automatic-teslamate-backup-to-google-drive/
      tmbackup = {
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ]; # systemd-networkd-wait-online.service
        script = ''
          set -eux
          now=$(date +"%A")
          cd /home/pi/teslamate || exit
          ${pkgs.docker}/bin/docker compose exec -T database pg_dump -U teslamate teslamate | ${pkgs.gzip}/bin/gzip -c > /home/pi/teslamate/tmbackup/teslamate.bck_$now.gz
          ${pkgs.rclone}/bin/rclone copy --max-age 24h /home/pi/teslamate/tmbackup --include 'teslamate.*' gdrive-service:TeslaMate '';
        serviceConfig = {
          Type = "oneshot";
          User = "root";
        };
      };
      habackup = {
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ]; # systemd-networkd-wait-online.service
        script = ''
          set -eux
          now=$(date +"%A")
          cd /home/pi/homeass || exit
          ${pkgs.gnutar}/bin/tar c config/ | ${pkgs.gzip}/bin/gzip -c > habackup/homeass.bck_$now.tar.gz
          ${pkgs.rclone}/bin/rclone copy --max-age 24h /home/pi/homeass/habackup --include 'homeass.*' gdrive-service:HomeAssistant
        '';
        serviceConfig = {
          Type = "oneshot";
          User = "root";
        };
      };
    };
  };

  powerManagement.cpuFreqGovernor = "ondemand";

  networking.firewall.allowedTCPPorts = [
    8123
    1883 # mqtt Mosquitto from teslamate docker-compose
  ];

  services.sshd.enable = true;

  services.cron.enable = false;

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
  swapDevices = [{ label = "swap"; }];
}
