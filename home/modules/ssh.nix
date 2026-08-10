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
            ForwardAgent = true;
            IdentityAgent = ''"${agentPath "~"}"'';
          }
        else matchBlock;
      knownHosts = {
        "rpi4" = {
          "rpi4" = withAgent {
            HostName = "192.168.1.40";
            User = "pi";
          };
          "ssh.chrstnsn.dk" = withAgent {
            User = "pi";
            ProxyCommand = "${pkgs.cloudflared}/bin/cloudflared access ssh --hostname %h";
          };
        };
        "aero-nix" = {
          "aero-nix" = withAgent {
            User = "thomas";
            HostName = "192.168.1.193";
          };
        };
        "enix" = {
          "enix" = withAgent {
            User = "thomas";
            HostName = "192.168.1.163";
          };
          "enix.chrstnsn.dk" = withAgent {
            User = "thomas";
            ProxyCommand = "${pkgs.cloudflared}/bin/cloudflared access ssh --hostname %h";
          };
        };
        cyrus = {
          cyrus = withAgent { User = "thomas"; HostName = "192.168.1.142"; };
        };
        "rsync.net" = {
          "rsync.net" = withAgent {
            User = "zh4414";
            HostName = "zh4414.rsync.net";
          };
        };
        "mft-az" =
          let
            az_options = {
              ForwardAgent = false;
              IdentitiesOnly = true;
              IdentityAgent = "none";
              User = "tfc-admin@mft-energy.com";
              CertificateFile = "/Users/tfc/.ssh/az_ssh_config/all_ips/id_rsa.pub-aadcert.pub";
              IdentityFile = "/Users/tfc/.ssh/az_ssh_config/all_ips/id_rsa";
            };
          in
          {
            "lazertrader-dev" = az_options // { HostName = "10.100.128.4"; };
            "rusty-worker-lnx-d-01" = az_options // { HostName = "10.100.128.7"; };
            "lazertrader-prod-old" = az_options // { HostName = "10.100.0.5"; };
            "lazertrader-prod" = az_options // { HostName = "10.100.0.8"; };
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

          settings = mkMerge [
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
      (mkIf (builtins.elem "mft-az" cfg.hosts) {
        home.file."bin/az-sshconfig.sh" = {
          source = ./azure/az-sshconfig.sh;
          executable = true;
        };
        # Must come after every Host block: `Match host` compares against the
        # hostname *after* HostName substitution, so the 10.100.*.* pattern only
        # matches `lazertrader-prod` and friends once their HostName has been seen.
        programs.ssh.settings.az-match =
          let
            azHosts = "10.100.*.*";
            script = "${config.home.homeDirectory}/bin/az-sshconfig.sh";
          in
          lib.hm.dag.entryAfter (attrNames (hostsToMatchblocks cfg.hosts)) {
            header = ''Match host "${azHosts}" exec "${script} > /dev/null"'';
            IdentityFile = "~/.ssh/az_ssh_config/all_ips/id_rsa";
          };
      })
    ]
  );
}
