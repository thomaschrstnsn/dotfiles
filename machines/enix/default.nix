{ inputs, sshKeys, ... }:

let
  username = "thomas";
in
{
  home = [{
    user = {
      inherit username;
      homedir = "/home/thomas";
    };
    direnv.enable = true;
    jj = {
      enable = true;
      publicKeyFile = "~/.ssh/github-personal.pub";
    };
    ssh = {
      enable = true;
      hosts = [ "rpi4" "enix" "rsync.net" ];
      publicKeys = {
        "github-personal.pub" = sshKeys.personal.access.publicKey;
      };
    };
    fish.enable = true;
    git = {
      enable = true;
      publicKeyFile = "~/.ssh/github-personal.pub";
    };
    tmux = {
      enable = true;
      remote = true;
      theme = "rose-pine";
    };
    lazyvim.enable = true;
  }];
  extraPackages = pkgs: with pkgs; [
    devenv
    lnav
    natscli
  ];

  system = "x86_64-linux";

  nixos = {
    config = {
      networking.hostname = "enix";
      user = {
        name = username;
        groups = [ "wheel" "docker" "navidrome" ];
        defaultShell = "fish";
      };
      services.nats.enable = true;
    };
    base = {
      imports =
        [
          ./hardware.nix
          ./configuration.nix

          inputs.screentime.nixosModules.web
          {
            services.screentime-web = {
              enable = true;
              natsUrl = "nats://localhost:4222";
              listenAddress = "0.0.0.0"; # the cloudflare tunnel on rpi4 reaches it over the LAN
              openFirewall = true;
              cloudflareAccess = {
                team = "chrstnsn";
                aud = "dc7601a2fd567cb444c9903776b771765ecb853bdcde878c3f136be1534c7de5";
              };
            };
          }
        ];
    };
  };
}
