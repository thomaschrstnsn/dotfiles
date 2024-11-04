{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.nushell;
  ssh-cfg = config.tc.ssh;
in
{
  options.tc.nushell = with types; {
    enable = mkEnableOption "nushell with settings";

    extraAliases = mkOption {
      description = "Extra aliases for nushell";
      type = attrs;
      default = { };
    };
    vi-mode.enable = mkEnableOption "vi mode in nushell" // { default = true; };
  };

  config = mkIf cfg.enable {

    home.packages = with pkgs; [
    ];

    programs.nushell = {
      enable = true;
      extraConfig = ''
        let carapace_completer = {|spans|
        carapace $spans.0 nushell $spans | from json
        }
        $env.config = {
         show_banner: false,
         completions: {
         case_sensitive: false # case-sensitive completions
         quick: true    # set to false to prevent auto-selecting completions
         partial: true    # set to false to prevent partial filling of the prompt
         algorithm: "fuzzy"    # prefix or fuzzy
         external: {
         # set to false to prevent nushell looking into $env.PATH to find more suggestions
             enable: true
         # set to lower can improve completion performance at the cost of omitting some options
             max_results: 100
             completer: $carapace_completer # check 'carapace_completer'
           }
         }
        }
        $env.PATH = ($env.PATH |
          split row (char esep) |
          prepend ~/bin |
          append /usr/bin/env
        )
      '';

      shellAliases = { } // cfg.extraAliases;
    };

    # programs.atuin.enableNushellIntegration = true;
    programs.direnv.enableNushellIntegration = true;
    programs.eza.enableNushellIntegration = true;
    programs.starship.enableNushellIntegration = true;
    programs.zoxide.enableNushellIntegration = true;

    programs.carapace = {
      enable = true;
      enableNushellIntegration = true;
    };
  };
}
