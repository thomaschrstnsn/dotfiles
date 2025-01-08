{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.sesh;
in
{
  options.tc.sesh = with types; {
    enable = mkEnableOption "sesh (tmux session tool)" // { default = true; };

    extraSessionConfig = mkOption {
      type = str;
      default = "";
      description = "extra configurations to add";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ sesh gum ];

    xdg.configFile."sesh/sesh.toml".text = ''
      [[session]]
      name = "Downloads 📥"
      path = "~/Downloads"
      startup_command = "yazi"

      [[session]]
      name = "dotfiles 🧑‍💻⚙️"
      path = "~/dotfiles"
      startup_command = "${./sesh/vim_and_shell.sh}"

    '' + cfg.extraSessionConfig;

    programs.zoxide = {
      enable = true;
    };
  };
}
