{ pkgs, config, lib, ... }:
with lib;

let cfg = config.tc.git;
in {
  options.tc.git = {
    enable = mkOption {
      description = "Enable git";
      type = types.bool;
      default = true;
    };

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
      default = ["github.com"];
    };
  };

  config = mkIf (cfg.enable) {
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

      extraConfig = {
        push.default = "current";
        branch.autosetuprebase = "always";
        url = builtins.listToAttrs (
          map 
            (gh: { 
              name = "git@" + gh + ":"; 
              value = { insteadOf = "https://"+gh;};
              }
            )
            cfg.githubs
          ); 
      };

      ignores = [ "*~" "*.swp" ".DS_Store" ];

      delta = {
        enable = true;
        options = {
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

    programs.zsh.shellAliases = {
      gs = "git st";
      gc = "git clone";
    };
  };
}