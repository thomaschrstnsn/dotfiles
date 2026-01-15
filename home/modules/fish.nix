{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.fish;
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

      functions = {
        kill_port = ''${pkgs.lsof}/bin/lsof -i TCP:$argv[1] | grep LISTEN | awk '{print $2}' | xargs kill -9'';
        take = ''mkdir -p $argv && cd $argv'';
      };

      interactiveShellInit = lib.mkOrder 1000 (
        ''
          set PATH $PATH ~/bin

          fish_config theme choose "ayu Mirage"
          set fish_greeting ""

          functions --erase lt # conflict with lt tool

          if test -f ~/.env
            fenv source ~/.env
          end

          set -g fish_key_bindings fish_vi_key_bindings
        ''
      );

      plugins = with pkgs.fishPlugins; [
        { name = "foreign-env"; src = foreign-env.src; }
        {
          name = "fifc";
          src = pkgs.fetchFromGitHub {
            owner = "gazorby";
            repo = "fifc";
            rev = "a01650cd432becdc6e36feeff5e8d657bd7ee84a";
            hash = "sha256-Ynb0Yd5EMoz7tXwqF8NNKqCGbzTZn/CwLsZRQXIAVp4=";
          };
        }
      ];

      shellAliases = mkMerge [
        {
          cat = "bat";
          man = "batman";
          reload_fish = "exec fish";
          gtime = ''${pkgs.time}/bin/time'';
        }
        cfg.extraAliases
      ];

      shellAbbrs = {
        j = "just";
        "..." = "cd ../..";
      };
    };
  };
}

