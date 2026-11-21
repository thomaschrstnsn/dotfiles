{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.yazi;

  yaziFlavors = pkgs.fetchFromGitHub {
    owner = "yazi-rs";
    repo = "flavors";
    rev = "38c08d8eb9ea0d28c8c911a249a08f27ba2151ac";
    sha256 = "sha256-lITDt1QvL54u6gbJiGixPyP6lk72f3rkiNPDrUg6G8I=";
  };

  yaziPlugins = pkgs.fetchFromGitHub
    {
      owner = "yazi-rs";
      repo = "plugins";
      rev = "1ef5fe02a6122f8f3bb47a41056aab3f4b8598bf";
      sha256 = "sha256-Nz6AvWAiwdmH2HJ2vA3rMfbDDHSkXG20Ml6vc5yrjRM=";
    };
in
{
  options.tc.yazi = with types;
    {
      enable = mkEnableOption "yazi" // { default = true; };
    };

  config = mkIf cfg.enable {
    programs.yazi = {
      enable = true;
      flavors = {
        catppuccin-mocha = "${yaziFlavors}/catppuccin-mocha.yazi";
      };
      plugins = {
        jump-to-char = "${yaziPlugins}/jump-to-char.yazi";
        smart-enter = "${yaziPlugins}/smart-enter.yazi";
        git = "${yaziPlugins}/git.yazi";
      };
      shellWrapperName = "y";
      settings = {
        log = {
          enabled = false;
        };
        mgr = {
          show_hidden = true;
          sort_by = "mtime";
          sort_dir_first = true;
          sort_reverse = true;
        };
        preview = {
          max_width = 1000;
          max_height = 1000;
        };
        plugin = {
          prepend_fetchers = [
            { group = "git"; url = "*"; run = "git"; }
            { group = "git"; url = "*/"; run = "git"; }
          ];
        };
      };
      initLua = ''
        require("git"):setup()
      '';
      keymap = {
        mgr.prepend_keymap = [
          { run = "plugin jump-to-char"; on = [ "f" ]; }
          { run = "plugin smart-enter"; on = [ "l" ]; }
          { run = "plugin smart-enter"; on = [ "<Enter>" ]; }
          { run = "leave"; on = [ "-" ]; }
        ];
      };
    };
  };
}
