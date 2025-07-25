{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.shell;
  mkIfList = cond: xs: if cond then xs else [ ];
in
{
  options.tc.shell = with types; {
    enable = (mkEnableOption "default shell env") // { default = true; };

    editor = mkOption {
      description = "Set $EDITOR (for cmdline git etc)";
      type = str;
      default = "nvim";
    };

    bat.theme = mkOption {
      description = "Theme for sharkdp/bat";
      type = enum [ "tokyo-night" "rose-pine" "rose-pine-dawn" "rose-pine-moon" ];
      default = "rose-pine";
    };
  };

  config = mkIf cfg.enable {

    programs.starship = mkMerge [{
      enable = true;
      settings = {
        aws = {
          format = "on $symbol ($profile) ($style)";
          symbol = "";
        };
        directory = {
          truncation_symbol = "…/";
        };
      };
    }];

    home.packages = with pkgs; [
      bottom
      du-dust
      dua # disk usage analyzer - `$ dua i`
      lazydocker
      fd
      file
      jq
      tree
      wget
    ] ++ mkIfList pkgs.stdenv.isLinux [ dysk ];

    home.shellAliases = mkIf pkgs.stdenv.isLinux {
      df = "dysk";
    };

    programs.eza = {
      enable = true;
    };

    programs.bat = {
      enable = true;
      extraPackages = with pkgs.bat-extras; [ batman ];
      config.theme = {
        "tokyo-night" = "enki-tokyo-night";
      }.${cfg.bat.theme} or cfg.bat.theme;

      themes =
        let
          rose-pine-src = pkgs.fetchFromGitHub {
            owner = "rose-pine";
            repo = "tm-theme";
            rev = "c4cab0c431f55a3c4f9897407b7bdad363bbb862";
            sha256 = "sha256-maQp4QTJOlK24eid7mUsoS7kc8P0gerKcbvNaxO8Mic";
          };
        in
        {
          # enki: https://github.com/enkia/enki-theme
          enki-tokyo-night = {
            src = pkgs.fetchFromGitHub {
              owner = "enkia";
              repo = "enki-theme"; # Bat uses sublime syntax for its themes
              rev = "0b629142733a27ba3a6a7d4eac04f81744bc714f";
              sha256 = "sha256-Q+sac7xBdLhjfCjmlvfQwGS6KUzt+2fu+crG4NdNr4w=";
            };
            file = "scheme/Enki-Tokyo-Night.tmTheme";
          };
          rose-pine-moon = {
            src = rose-pine-src;
            file = "dist/themes/rose-pine-moon.tmTheme";
          };
          rose-pine-dawn = {
            src = rose-pine-src;
            file = "dist/themes/rose-pine-dawn.tmTheme";
          };
          rose-pine = {
            src = rose-pine-src;
            file = "dist/themes/rose-pine.tmTheme";
          };
        };
    };

    programs.fzf = {
      enable = true;
      fileWidgetCommand = "fd --type f --type d --type symlink";
      defaultCommand = "fd --type f";
      changeDirWidgetCommand = "fd --type d";
    };

    programs.htop.enable = true;

    programs.btop = {
      enable = true;
    };

    programs.home-manager.enable = true;
    xdg.enable = true;

    home.sessionVariables = {
      EDITOR = cfg.editor;
      # XDG_CONFIG_HOME = "${config.home}/.config";
    };

    programs.atuin = {
      enable = true;
      # https://docs.atuin.sh/configuration/config/
      settings = {
        filter_mode_shell_up_key_binding = "directory";
        filter_mode = "global";
        search_mode_shell_up_key_binding = "fuzzy";
        search_mode = "fuzzy";
        style = "compact";
      };
    };
  };
}
