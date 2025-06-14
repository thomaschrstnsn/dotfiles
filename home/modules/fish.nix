{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.fish;
  ssh-cfg = config.tc.ssh;
  shell = config.tc.shell;
in
{
  options.tc.fish = with types; {
    enable = mkEnableOption "fish with settings";

    extraAliases = mkOption {
      description = "Extra aliases for fish";
      type = attrs;
      default = { };
    };
  };

  config = mkIf cfg.enable {

    home.shell.enableFishIntegration = true;

    programs.fish = {
      enable = true;
      interactiveShellInit = lib.mkOrder 1000 (
        ''
          set PATH $PATH ~/bin

          # function killport() { lsof -i TCP:$1 | grep LISTEN | awk '{print $2}' | xargs kill -9 }
        ''
      );

      shellAliases = mkMerge [
        {
          cat = "bat";
          man = "batman";
          # reload_fishrc = "source ~/.fishrc";
          gtime = ''${pkgs.time}/bin/time'';
        }
        cfg.extraAliases
      ];
    };
  };
}

