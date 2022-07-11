{ config, lib, pkgs, modulesPath, ... }:

{
          # Use the systemd-boot EFI boot loader.
        boot.loader.systemd-boot.enable = true;
        boot.loader.efi.canTouchEfiVariables = true;

        networking.hostName = "vmnix"; # Define your hostname.
        # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

        # Set your time zone.
        time.timeZone = "Europe/Copenhagen";

        # The global useDHCP flag is deprecated, therefore explicitly set to false here.
        # Per-interface useDHCP will be mandatory in the future, so this generated config
        # replicates the default behaviour.
        networking.useDHCP = false;
        networking.interfaces.enp0s6.useDHCP = true;

        # programs.zsh = {
        #   enable = true;
        #   syntaxHighlighting.enable = true;
        #   interactiveShellInit = ''
        #     source ${pkgs.grml-zsh-config}/etc/zsh/zshrc
        #   '';
        #   promptInit = ""; # otherwise it'll override the grml prompt
        # };

        users = {
          defaultUserShell = pkgs.zsh;
          mutableUsers = false;
          users.thomas = {
            isNormalUser = true;
            hashedPassword = "$6$LCmCC873.y/MhqLa$xrTZFdCYmo.FfCk1fkYCVNvVR1Xq1SrFAoD2a94pYlL7uk0apnrbJJbJIuo6WKofuA3egt7DOEasM44vyPJyZ.";
            extraGroups = [ "wheel" ];
            openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICTvFy5gC46MnA0Eu+DoYQbldwxoJJVd9KVpAFwkS+ZH" ];
          };
        };

        environment.variables = {
          EDITOR = "vim";
        };

        services.openssh.enable = true;

        nix = {
          package = pkgs.nixUnstable;
          autoOptimiseStore = true;
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

        system.stateVersion = "21.05";

}