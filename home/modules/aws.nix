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
      k9s
      saml2aws
      ssm-session-manager-plugin
      terraform-ls
      tfswitch
    ];

    programs.zsh.oh-my-zsh.plugins = [ "terraform" "aws" ];

    programs.zsh.initExtra = ''
      export PATH=~/bin:$PATH

      export AWS_PROFILE="pre"
    '';

    programs.zsh.shellAliases = {
      rdp2bastion = ''(cd ~/src/aws-cli-tooling/bastion; AWS_PROFILE=pro-devops python3 rdp2bastion.py)'';
    };
  };
}
