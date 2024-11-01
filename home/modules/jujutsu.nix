{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.jj;
  sshConfig = config.tc.ssh;
in
{
  options.tc.jj = with types; {
    enable = mkEnableOption "jujutsu vcs";

    userName = mkOption {
      description = "Name for jj";
      type = types.str;
      default = "Thomas Christensen";
    };

    userEmail = mkOption {
      description = "Email for jj";
      type = types.str;
      default = "thomas@chrstnsn.dk";
    };

    differ = mkOption {
      type = enum [ "standard" "delta" "difftastic" ];
      default = "delta";
    };

    gpgVia1Password = mkEnableOption "Use 1Password for GPG signing";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs;
      (if (cfg.differ == "difftastic")
      then [ difftastic ]
      else [ ]) ++ [
        lazyjj
      ];

    programs.jujutsu = {
      enable = true;
      settings = {
        user = {
          name = cfg.userName;
          email = cfg.userEmail;
        };
        signing = {
          key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIErz7lXsjPyJcjzRKMWyZodRGzjkbCxWu/Lqk+NpjupZ";
          backend = "ssh";
          backends.ssh.program = config.programs.git.extraConfig.gpg.ssh.program;
          sign-all = (sshConfig.use1PasswordAgent && cfg.gpgVia1Password);
        };
        ui = {
          pager = "delta";
          diff.format = "git";
          default-command = "log";
        };
        aliases = {
          e = [ "edit" ];
          stash = [ "new" "@-" ];
          des = [ "describe" "-m" ];
        };
      };
    };

    programs.zsh.shellAliases = {
      js = "jj st";
      jd = "jj diff";
      jc = "jj git clone";
      jp = "jj git push";
      jf = "jj git fetch";
      je = "jj edit";
      jgc = "jj git clone --colocate";
    };
  };
}
