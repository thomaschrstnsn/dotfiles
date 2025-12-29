{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.yazi;

  yaziFlavors = pkgs.fetchFromGitHub {
    owner = "yazi-rs";
    repo = "flavors";
    rev = "9276ffacbfffe1f2d0fa9df9efef07f36896c353";
    sha256 = "sha256-1IgX6R+0lPVl0r9WcyNkrvFzG6VaWgMklyOUHrxZ4Zg";
  };

  yaziPlugins = pkgs.fetchFromGitHub
    {
      owner = "yazi-rs";
      repo = "plugins";
      rev = "7ca66b4103d76038a5d21c9b83766967f5028116";
      sha256 = "sha256-G4Pqb8ct7om4UfihGr/6GoUn69HbzFVTxlulTeXZyEk";
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
            { id = "git"; name = "*"; run = "git"; }
            { id = "git"; name = "*/"; run = "git"; }
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
