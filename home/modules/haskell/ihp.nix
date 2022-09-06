{ pkgs, config, lib, ... }:
with lib;

let cfg = config.tc.haskell.ihp;
in
{
  options.tc.haskell.ihp = {
    enable = mkEnableOption "ihp";
  };

  config = mkIf (cfg.enable) {
    home.packages = with pkgs; [
      cachix
    ];

    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
    };

    programs.zsh.initExtra = ''
      export IHP_EDITOR="code --goto"
    '';
  };
}
