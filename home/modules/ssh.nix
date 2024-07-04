{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.ssh;
in
{
  options.tc.ssh = with types; {
    enable = mkEnableOption "ssh";
    hosts = mkOption {
      type = listOf (enum [ "rpi4" "vmnix" "aero-nix" "enix" "rsync.net" "logseq-personal-deploy" ]);
      default = [ ];
      description = "known hosts to add to ssh config";
    };
    addLindHosts = mkEnableOption "add Lind hosts";
    use1PasswordAgentOnMac = mkEnableOption "1Password ssh-agent on mac";
    agent.enable = mkEnableOption "ssh-agent enabled";
    includes = mkOption
      {
        type = listOf str;
        description = "files to be Include'd";
        default = [ ];
      };
  };

  config = mkIf cfg.enable (
    let
      t1user = "t1tfc@local-lindcapital.dk";
      lindHosts = [
        "stlcevs01"
        "stlcevs02"
        "stlcevs03"
        "stlcunixhost02"
        "lcevs04"
        "lcevs05"
        "lcunixhost01"
        "lcunixhost02"
        "vmlcunixhost10"
      ];
      devUser = "dev";
      lindDevHosts = [
        "lcunixbld01"
      ];
      knownHosts = {
        "rpi4" = {
          "rpi4" = {
            hostname = "192.168.1.40";
            user = "pi";
          };
          "ssh.chrstnsn.dk" = {
            user = "pi";
            proxyCommand = "${pkgs.cloudflared}/bin/cloudflared access ssh --hostname %h";
          };
        };
        "aero-nix" = {
          "aero-nix" = {
            user = "thomas";
            hostname = "192.168.1.193";
          };
        };
        "vmnix" = {
          "vmnix" = {
            user = "thomas";
            hostname = "192.168.64.6";
          };
        };
        "enix" = {
          "enix" = {
            user = "thomas";
            hostname = "192.168.1.163";
          };
          "enix.chrstnsn.dk" = {
            user = "thomas";
            proxyCommand = "${pkgs.cloudflared}/bin/cloudflared access ssh --hostname %h";
          };
        };
        "rsync.net" = {
          "rsync.net" = {
            user = "zh4414";
            hostname = "zh4414.rsync.net";
          };
        };
        "logseq-personal-deploy" = {
          "logseq-personal-deploy" = {
            user = "git";
            hostname = "github.com";
            identityFile = "~/.ssh/logseq-personal-deploy_ed25519";
            identitiesOnly = true;
          };
        };
      };

      hostsToMatchblocks =
        hosts: (
          let
            hostAttrs = map (h: getAttr h knownHosts) hosts;
          in
          foldl' (s1: s2: s1 // s2) { } hostAttrs
        );
    in
    mkMerge [
      {
        programs.ssh = {
          enable = true;
          forwardAgent = true;
          extraConfig =
            if cfg.use1PasswordAgentOnMac
            then ''
              IdentityAgent = "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
            ''
            else "";

          matchBlocks = mkMerge [
            (hostsToMatchblocks cfg.hosts)
            (mkIf cfg.addLindHosts
              (listToAttrs (map
                (h: {
                  name = h;
                  value = {
                    user = devUser;
                    hostname = h;
                  };
                })
                lindDevHosts))
            )
            (mkIf cfg.addLindHosts
              (listToAttrs (map
                (h: {
                  name = h;
                  value = {
                    user = t1user;
                    hostname = h;
                  };
                })
                lindHosts))
            )
          ];

          includes = cfg.includes;
        };
      }
      (mkIf cfg.use1PasswordAgentOnMac
        {
          home.file = {
            ".config/1Password/ssh/agent.toml".text = ''
              [[ssh-keys]]
              item = "abzfs445wgvufgybncdcjgptla"

              [[ssh-keys]]
              item = "6ddacbrzis56q7qmq5bkinjsum"
            '';
          };
        })
    ]
  );
}
