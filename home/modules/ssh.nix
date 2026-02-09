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
      type = listOf (enum [ "rpi4" "aero-nix" "cyrus" "enix" "rsync.net" "mft-az" ]);
      default = [ ];
      description = "known hosts to add to ssh config";
    };
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
      withAgent = matchBlock:
        if cfg._1password.enableAgent
        then
          matchBlock // {
            forwardAgent = true;
            identityAgent = ''"${agentPath "~"}"'';
          }
        else matchBlock;
      knownHosts = {
        "rpi4" = {
          "rpi4" = withAgent {
            hostname = "192.168.1.40";
            user = "pi";
          };
          "ssh.chrstnsn.dk" = withAgent {
            user = "pi";
            proxyCommand = "${pkgs.cloudflared}/bin/cloudflared access ssh --hostname %h";
          };
        };
        "aero-nix" = {
          "aero-nix" = withAgent {
            user = "thomas";
            hostname = "192.168.1.193";
          };
        };
        "enix" = {
          "enix" = withAgent {
            user = "thomas";
            hostname = "192.168.1.163";
          };
          "enix.chrstnsn.dk" = withAgent {
            user = "thomas";
            proxyCommand = "${pkgs.cloudflared}/bin/cloudflared access ssh --hostname %h";
          };
        };
        cyrus = {
          cyrus = withAgent { user = "thomas"; hostname = "192.168.1.142"; };
        };
        "rsync.net" = {
          "rsync.net" = withAgent {
            user = "zh4414";
            hostname = "zh4414.rsync.net";
          };
        };
        "mft-az" =
          let
            az_options = {
              forwardAgent = false;
              identitiesOnly = true;
              identityAgent = "none";
              user = "tfc-admin@mft-energy.com";
              certificateFile = "/Users/tfc/.ssh/az_ssh_config/all_ips/id_rsa.pub-aadcert.pub";
              identityFile = "/Users/tfc/.ssh/az_ssh_config/all_ips/id_rsa";
            };
          in
          {
            "10.100.*.*" = az_options;
            "lazertrader-dev" = az_options // { hostname = "10.100.128.4"; };
            "lazertrader-prod" = az_options // { hostname = "10.100.0.5"; };
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
          enableDefaultConfig = false;

          matchBlocks = mkMerge [
            (hostsToMatchblocks cfg.hosts)
            { "*" = withAgent { }; }
          ];

          inherit (cfg) includes;
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
