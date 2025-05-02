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

    gpgVia1Password = mkEnableOption "Use 1Password for GPG signing";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs;
      [
        # lazyjj # broken currently on nixpkgs
      ];

    programs.jujutsu = mkMerge [{
      enable = true;
      settings = {
        user = {
          name = cfg.userName;
          email = cfg.userEmail;
        };
        ui = {
          pager = "delta";
          diff.format = "git";
          default-command = "log-recent";
          diff-editor = "gitpatch";
        };
        aliases = {
          e = [ "edit" ];
          stash = [ "new" "@-" ];
          des = [ "describe" "-m" ];
          log-recent = [ "log" "-r" "default() & recent()" ];
          tug = [ "bookmark" "move" "--from" "closest_bookmark(@-)" "--to" "@-" ];
        };
        revset-aliases = {
          "recent()" = ''committer_date(after:"3 months ago")'';
          "closest_bookmark(to)" = "heads(::to & bookmarks())";
          "default()" = "present(@) | ancestors(immutable_heads().., 2) | present(trunk())";
        };
        git = {
          push-new-bookmarks = true;
        };
        # https://zerowidth.com/2025/jj-tips-and-tricks/#hunk-wise-style
        merge-tools.gitpatch = {
          program = "sh";
          edit-args = [
            "-c"
            ''
              set -eu
              rm -f "$right/JJ-INSTRUCTIONS"
              git -C "$left" init -q
              git -C "$left" add -A
              git -C "$left" commit -q -m baseline --allow-empty
              mv "$left/.git" "$right"
              git -C "$right" add --intent-to-add -A
              git -C "$right" add -p
              git -C "$right" diff-index --quiet --cached HEAD && { echo "No changes done, aborting split."; exit 1; }
              git -C "$right" commit -q -m split
              git -C "$right" restore . # undo changes in modified files
              git -C "$right" reset .   # undo --intent-to-add
              git -C "$right" clean -q -df # remove untracked files
            ''
          ];
        };
      };
    }
      (mkIf (sshConfig.use1PasswordAgent && cfg.gpgVia1Password)
        {
          settings.signing = {
            key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIErz7lXsjPyJcjzRKMWyZodRGzjkbCxWu/Lqk+NpjupZ";
            backend = "ssh";
            backends.ssh.program = config.programs.git.extraConfig.gpg.ssh.program;
            behavior = "own";
          };
        })];

    home.shellAliases = {
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
