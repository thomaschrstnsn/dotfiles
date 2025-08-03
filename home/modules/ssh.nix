{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.ssh;
  agentPath = homePart:
    if pkgs.stdenv.isDarwin then
      "${homePart}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
    else
      "${homePart}/.1password/agent.sock";
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
    _1password.enableAgent = mkEnableOption "1Password ssh-agent";
    _1password.keys = mkOption {
      type = listOf str;
      description = "ssh keys (by item id) to use from 1password (item id: https://www.1password.community/discussions/1password/view-item-uuid-from-ui/60675)";
    };
    publicKeys = mkOption {
      type = attrsOf str;
      description = ''public keys to write into ~/.ssh/, e.g. {github = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIErz7lXsjPyJcjzRKMWyZodRGzjkbCxWu/Lqk+NpjupZ";
";}'';
      default = { };
    };
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
        "stlcubuk8s01"
        "stlcubuk8s02"
        "stlcubuk8s03"
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
            if cfg._1password.enableAgent
            then ''
              IdentityAgent = "${agentPath "~"}"
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
      (mkIf cfg._1password.enableAgent (
        let
          generateSshKeyLines = keys:
            lib.concatMapStrings
              (key: ''
                [[ssh-keys]]
                item = "${key}"

              '')
              keys;
        in
        {
          programs.zsh.initContent = lib.mkOrder 550 ''
            export SSH_AUTH_SOCK="${agentPath (if pkgs.stdenv.isDarwin then "/Users/$USER" else "/home/$USER")}";
          '';
          programs.fish.interactiveShellInit = lib.mkOrder 550 ''
            set SSH_AUTH_SOCK "${agentPath (if pkgs.stdenv.isDarwin then "/Users/$USER" else "/home/$USER")}";
          '';
          home.file = {
            ".config/1Password/ssh/agent.toml".text = generateSshKeyLines cfg._1password.keys;
          };
        }
      ))
      {
        home.file =
          lib.mapAttrs'
            (name: content: lib.nameValuePair ".ssh/${name}" { text = content; })
            cfg.publicKeys;
      }
    ]
  );
}
