{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.shell;
in
{
  options.tc.shell = with types; {
    enable = (mkEnableOption "default shell env") // { default = true; };
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
      lnav
      fd
      file
      jq
      tree
      wget
    ];

    programs.eza = {
      enable = true;
      enableZshIntegration = true;
    };

    programs.bat = {
      enable = true;
      extraPackages = with pkgs.bat-extras; [ batman ];
      config.theme = "enki-tokyo-night";
      themes = {
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
