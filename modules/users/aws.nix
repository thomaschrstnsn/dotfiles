{ pkgs, config, lib, ... }:
with lib;

let 
  cfg = config.tc.aws;
in {
  options.tc.aws = {
    enable = mkOption {
      description = "Enable aws + terraform";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable) {
    home.packages = with pkgs; [
      awscli2
      terraform
    ];

    programs.zsh.sessionVariables = {
      AWS_PROFILE = "playground";
    };

    programs.zsh.oh-my-zsh.plugins = [ "terraform" "aws" ];
  };
}
