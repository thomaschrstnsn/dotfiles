{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.aws;
in
{
  options.tc.aws = {
    enable = mkEnableOption "aws + terraform";
  };

  config = mkIf (cfg.enable) {
    home.packages = with pkgs; [
      awscli2
      saml2aws
      tfswitch
      terraform-ls
    ];

    programs.zsh.sessionVariables = {
      AWS_PROFILE = "playground";
    };

    programs.zsh.oh-my-zsh.plugins = [ "terraform" "aws" ];

    programs.zsh.initExtra = ''
      export PATH=~/bin:$PATH
    '';
  };
}
