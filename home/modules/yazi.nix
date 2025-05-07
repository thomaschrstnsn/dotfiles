{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.yazi;

  yaziFlavors = pkgs.fetchFromGitHub {
    owner = "yazi-rs";
    repo = "flavors";
    rev = "68326b4ca4b5b66da3d4a4cce3050e5e950aade5";
    sha256 = "sha256-nhIhCMBqr4VSzesplQRF6Ik55b3Ljae0dN+TYbzQb5s";
  };

  yaziPlugins = pkgs.fetchFromGitHub
    {
      owner = "yazi-rs";
      repo = "plugins";
      rev = "864a0210d9ba1e8eb925160c2e2a25342031d8d3";
      sha256 = "sha256-m3709h7/AHJAtoJ3ebDA40c77D+5dCycpecprjVqj/k";
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
        manager = {
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
        manager.prepend_keymap = [
          { run = "plugin jump-to-char"; on = [ "f" ]; }
          { run = "plugin smart-enter"; on = [ "l" ]; }
          { run = "plugin smart-enter"; on = [ "<Enter>" ]; }
          { run = "leave"; on = [ "-" ]; }
        ];
      };
    };
  };
}
