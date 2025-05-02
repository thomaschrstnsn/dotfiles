{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.aws;
in
{
  options.tc.aws = {
    enable = mkEnableOption "aws, k8s, terraform";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      awscli2
      k9s
      saml2aws
      ssm-session-manager-plugin
      terraform-ls
      tfswitch
    ];

    programs.zsh.oh-my-zsh.plugins = [ "terraform" "aws" ];

    programs.zsh.initContent = ''
      export PATH=~/bin:$PATH
    '';
  };
}
