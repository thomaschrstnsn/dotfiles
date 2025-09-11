{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.jj;
  sshConfig = config.tc.ssh;

  preferFishAbbreviations = config.tc.fish.enable;
  abbrevationsAndAliases = {
    jc = "jj git clone";
    jd = "jj diff";
    je = "jj edit";
    jf = "jj git fetch";
    jgc = "jj git clone --colocate";
    jla = "jj log -r ::";
    jp = "jj git push";
    js = "jj st";
    jk = "jjui";
  };

  mkIfList = cond: xs: if cond then xs else [ ];
  alternativeConfigType = with types; submodule {
    options = {
      userName = mkOption {
        description = "Alternative config Name for jj";
        type = nullOr str;
        default = null;
      };

      userEmail = mkOption {
        description = "Alternative config Email for jj";
        type = nullOr str;
        default = null;
      };

      gpgVia1Password.key = mkOption {
        type = nullOr str;
        description = "sshkey from 1password for signing (public)";
        example = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIErz7lXsjPyJcjzRKMWyZodRGzjkbCxWu/Lqk+NpjupZ";
        default = null;
      };

      publicKeyFile = mkOption {
        type = nullOr str;
        description = "Which ssh-key (path to a public key for agent or private key on file) to prefer for connecting with ssh";
        example = "~/.ssh/github-alternative.pub";
        default = null;
      };
    };
  };
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

    starship.enable = mkEnableOption "Enable starship-jj integration";

    mergiraf.enable = mkEnableOption "mergiraf support" // { default = true; };

    difftastic.enable = mkEnableOption "Setup difftastic as diff tool (not default tool)" // { default = true; };

    meld.enable = mkEnableOption "Use meld as merge tool";

    gpgVia1Password.enable = mkEnableOption "Use 1Password for GPG signing";

    gpgVia1Password.key = mkOption {
      type = str;
      description = "sshkey from 1password for signing (public)";
    };

    publicKeyFile = mkOption {
      type = nullOr str;
      description = "Which ssh-key (path to a public key file) to prefer for connecting with ssh";
      example = "~/.ssh/github.pub";
      default = null;
    };

    alternativeConfigs = mkOption {
      type = attrsOf alternativeConfigType;
      description = "keyed by paths matching repositories, values are alternative configurations enabled";
      default = { };
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs;
      [
        jjui
      ]
      ++ mkIfList cfg.mergiraf.enable [ mergiraf ]
      ++ mkIfList cfg.difftastic.enable [ difftastic ]
      ++ mkIfList cfg.meld.enable [ meld ];

    programs.tmux.extraConfig = ''
      bind-key "C-j" display-popup -E -w 99% -h 99% "jjui"
      bind-key "C-l" display-popup -E -x R -h 99% "jj log --color=always | less -R"
      bind-key "l" display-popup -E -x R -h 99% "jj log --color=always -r :: | less -R"
    '';

    programs.jujutsu = mkMerge [{
      enable = true;
      settings =
        {
          user = {
            name = cfg.userName;
            email = cfg.userEmail;
          };
          ui = {
            pager = "delta";
            diff-formatter = ":git";
            default-command = "log-recent";
          };
          aliases = {
            e = [ "edit" ];
            stash = [ "new" "@-" ];
            des = [ "describe" "-m" ];
            log-recent = [ "log" "-r" "default(8) & recent()" ];
            tug = [ "bookmark" "move" "--from" "closest_bookmark(@-)" "--to" "closest_pushable(@-)" ];
            nb = [ "bookmark" "create" "-r" "@-" ];
          };
          revset-aliases = {
            "recent()" = ''committer_date(after:"3 months ago")'';
            "default(n)" = "present(@) | ancestors(immutable_heads().., n) | present(trunk())";
            # for tug: https://github.com/jj-vcs/jj/discussions/5568#discussioncomment-13034102
            "closest_bookmark(to)" = "heads(::to & bookmarks())";
            "closest_pushable(to)" = ''heads(::to & mutable() & ~description(exact:"") & (~empty() | merges()))'';
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
      (mkIf (sshConfig._1password.enableAgent && cfg.gpgVia1Password.enable)
        {
          settings.signing = {
            key = cfg.gpgVia1Password.key;
            backend = "ssh";
            backends.ssh.program = config.programs.git.extraConfig.gpg.ssh.program;
            behavior = "own";
          };
        })
      (mkIf cfg.mergiraf.enable
        {
          settings.aliases.mergiraf = [ "resolve" "--tool" "mergiraf" ];
        })
      (mkIf cfg.difftastic.enable
        {
          settings = {
            aliases.dt = [ "diff" "--tool" "difftastic" ];
            merge-tools.difftastic = {
              program = "difft";
              diff-args = [ "--color=always" "$left" "$right" ];
            };
          };
        })
      (mkIf cfg.meld.enable
        {
          settings = {
            aliases.meld = [ "resolve" "--tool" "meld" ];
          };
        })
      (mkIf (cfg.publicKeyFile != null) {
        settings.git.ssh-command = [ "ssh" "-i" cfg.publicKeyFile "-o" "IdentitiesOnly=yes" ];
      })];

    xdg.configFile =
      let
        mkOptionsFromAltCfg = altCfg: (
          {
            user.name = altCfg.userName;
            user.email = altCfg.userEmail;
            signing.key = altCfg.gpgVia1Password.key;
            git.ssh-command = if (altCfg.publicKeyFile != null) then [ "ssh" "-i" altCfg.publicKeyFile "-o" "IdentitiesOnly=yes" ] else [ "ssh" ];
          }
        );

        mkFile = index: path: altCfg:
          let
            deepFilterAttrs = pred: attrs:
              lib.filterAttrs (_: v: true) (
                builtins.mapAttrs
                  (_: v:
                    if builtins.isAttrs v then deepFilterAttrs pred v else v
                  )
                  (lib.filterAttrs pred attrs)
              );
            options = mkOptionsFromAltCfg altCfg;
            nonNullOptions = deepFilterAttrs (_: v: v != null) options;
            nonEmptyOptions = deepFilterAttrs (_: v: !(builtins.isAttrs v && builtins.attrNames v == [ ])) nonNullOptions;
          in
          {
            text = ''--when.repositories = [ "${path}" ]
          '' + (readFile ((pkgs.formats.toml { }).generate "alt-${toString index}.toml" nonEmptyOptions));
          };

        jjuiThemes = pkgs.fetchFromGitHub {
          owner = "vic";
          repo = "tinted-jjui";
          rev = "25dc3531e01fe155d4bdcf4bcb4b707fe5e56b3f";
          sha256 = "sha256-sT3TVSjGq5X/nJQtPQN4Kby7254udrZCAMAO5rCzUjk";
        };

      in
      mkMerge [
        {
          "jjui/themes/my-theme.toml" = { source = "${jjuiThemes}/themes/base16-rose-pine.toml"; };
        }
        {
          "jjui/config.toml" = {
            source = (pkgs.formats.toml { }).generate "jjui-config.toml" {
              revisions = {
                revset = "default(16) & recent()";
              };
              ui.theme = "my-theme";
              preview = {
                revision_command = [ "show" "-r" "$change_id" "--tool" "delta" ];
                file_command = [ "diff" "-r" "$change_id" "--tool" "delta" "$file" ];
              };
              custom_commands = {
                "split gitpatch" = {
                  args = [ "split" "--tool" "gitpatch" "-r" "$change_id" "$file" ];
                  key = [ "ctrl+s" ];
                  show = "interactive";
                };
                "show diff" = {
                  key = [ "U" ];
                  args = [ "diff" "--tool" "delta" "-r" "$change_id" "--color" "always" ];
                  show = "diff";
                };
                "resolve vscode" = {
                  key = [ "R" ];
                  args = [ "resolve" "--tool" "vscode" ];
                  show = "interactive";
                };
                tug = {
                  key = [ "t" ];
                  args = [
                    "bookmark"
                    "move"
                    "--from"
                    "closest_bookmark($change_id)"
                    "--to"
                    "closest_pushable($change_id)"
                  ];
                };
              };
            };
          };
        }
        # iterate over each alternativeConfig
        (
          listToAttrs (imap0
            (index: key: {
              name = "jj/conf.d/alternative-config-${toString(index)}.toml";
              value = mkFile index key (cfg.alternativeConfigs."${key}");
            })
            (attrNames cfg.alternativeConfigs))
        )
      ];

    programs.starship.settings.custom.jj = mkIf cfg.starship.enable {
      ## TODO: it seems we need to write the default config for it to work (0.3.2)
      ## ❯ /nix/store/ikxy2k01l8wnbdssc6l59v5ighzdc161-starship-jj-0.3.2/bin/starship-jj starship config default > "/Users/tfc/Library/Application Support/starship-jj/starship-jj.toml
      command = ''${pkgs.myPkgs.starship-jj}/bin/starship-jj --ignore-working-copy starship prompt'';
      format = "[$symbol](blue bold) $output ";
      symbol = "󱗆 ";
      when = "jj root --ignore-working-copy";
    };

    home.shellAliases = mkIf (!preferFishAbbreviations) abbrevationsAndAliases;
    programs.fish.shellAbbrs = mkIf preferFishAbbreviations abbrevationsAndAliases;
  };
}
