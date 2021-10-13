{ pkgs, config, lib, ... }:
with lib;

let cfg = config.tc.haskell.ihp;
in {
  options.tc.haskell.ihp = {
    enable = mkOption {
      description = "Enable ihp";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable) {
    home.packages = with pkgs; [
      cachix
    ];

    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
    };

    programs.zsh.sessionVariables = {
      IHP_EDITOR = "code --goto";
    };
  };
}
