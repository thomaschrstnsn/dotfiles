{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.tmux;
in
{
  config = mkIf (cfg.session-tool == "sesh") {

    xdg.configFile."sesh/sesh.toml".text = ''
    [[session]]
    name = "Downloads 📥"
    path = "~/Downloads"
    startup_command = "ls"

    [[session]]
    name = "dotfiles 🧑‍💻⚙️"
    path = "~/dotfiles"
    startup_script = "${./sesh/vim_and_shell.sh}"
    '';

    programs.zoxide = {
      enable = true;
    };
  };
}
