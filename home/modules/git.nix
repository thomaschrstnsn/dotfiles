{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.git;
  sshConfig = config.tc.ssh;
  mkIfList = cond: xs: if cond then xs else [ ];
in
{
  options.tc.git = with types; {
    enable = mkEnableOption "git";

    userName = mkOption {
      description = "Name for git";
      type = types.str;
      default = "Thomas Christensen";
    };

    userEmail = mkOption {
      description = "Email for git";
      type = types.str;
      default = "thomas@chrstnsn.dk";
    };

    githubs = mkOption {
      description = "Githubs to replace 'https:// to git@' with, so that you can git clone from the https url and still use ssh";
      type = types.listOf types.str;
      default = [ ];
    };

    differ = mkOption {
      type = enum [ "standard" "delta" "difftastic" ];
      default = "delta";
    };

    gpgVia1Password = mkEnableOption "Use 1Password for GPG signing";

    mergiraf.enable = mkEnableOption "mergiraf support" // { default = true; };
  };

  config = mkIf cfg.enable {

    home.packages = with pkgs;
      (mkIfList (cfg.differ == "difftastic") [ difftastic ]) ++
      (mkIfList cfg.mergiraf.enable [ mergiraf ]);

    programs.git = {
      enable = true;
      userName = cfg.userName;
      userEmail = cfg.userEmail;

      aliases = {
        st = "status -s";
        sm = "submodule";
        ci = "commit";
        cia = "commit -a";
        co = "checkout";
        nb = "checkout -b";
        br = "branch";
        l1 = "log --pretty=oneline";
        lol = "log --graph --decorate --pretty=oneline --abbrev-commit";
        lola = "log --graph --decorate --pretty=oneline --abbrev-commit --all";
        ff = "merge --ff-only";
      };

      extraConfig = mkMerge [
        {
          push.autoSetupRemote = "true"; # since 2.37.0
          push.default = "current";
          branch.autosetuprebase = "always";
          fetch.prune = "true";
          log.date = "iso";
          branch.sort = "committerdate";
          url = builtins.listToAttrs (
            map
              (gh: {
                name = "git@" + gh + ":";
                value = { insteadOf = "https://" + gh; };
              }
              )
              cfg.githubs
          );
        }
        (mkIf cfg.gpgVia1Password {
          user.signingkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIErz7lXsjPyJcjzRKMWyZodRGzjkbCxWu/Lqk+NpjupZ";
          gpg.format = "ssh";
          gpg.ssh.program =
            if pkgs.stdenv.isDarwin then
              "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
            else
              "${lib.getExe' pkgs._1password-gui "op-ssh-sign"}";
          commit.gpgsign = (sshConfig.use1PasswordAgent && cfg.gpgVia1Password);
        })
        (mkIf cfg.mergiraf.enable {
          merge.mergiraf = {
            name = "mergiraf";
            driver = "mergiraf merge --git %O %A %B -s %S -x %X -y %Y -p %P -l %L";
          };
        })
      ];

      attributes = mkIfList cfg.mergiraf.enable [
        "* merge=mergiraf"
      ];

      ignores = [ "*~" "*.swp" ".DS_Store" ".bacon-locations" ];

      delta = {
        enable = cfg.differ == "delta";
        options = {
          core-autocrlf = "input";
          features = "line-numbers decorations";
          whitespace-error-style = "22 reverse";
          decorations = {
            commit-decoration-style = "bold yellow box ul";
            file-style = "bold yellow ul";
            file-decoration-style = "none";
          };
        };
      };
    };

    home.shellAliases = {
      gs = "git st";
      gc = "git clone";
      gp = "git push -u"; # set upstream
    };
  };
}
