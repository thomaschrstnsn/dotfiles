{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.ssh;
in
{
  options.tc.ssh = with types; {
    enable = mkEnableOption "ssh";
    hosts = mkOption {
      type = listOf (enum [ "rpi4" "vmnix" "aero-nix" ]);
      default = [ ];
      description = "known hosts to add to ssh config";
    };
    use1PasswordAgentOnMac = mkEnableOption "1Password ssh-agent on mac";
    includes = mkOption
      {
        type = listOf str;
        description = "files to be Include'd";
        default = [ ];
      };
  };

  config = mkIf cfg.enable (
    let
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
            hostname = "192.168.64.4";
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
    {
      programs.ssh = {
        enable = true;
        forwardAgent = true;
        extraConfig =
          if cfg.use1PasswordAgentOnMac
          then ''IdentityAgent = "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"''
          else "";

        matchBlocks = hostsToMatchblocks cfg.hosts;

        includes = cfg.includes;
      };
    }
  );
}
