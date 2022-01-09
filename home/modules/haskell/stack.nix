{ pkgs, config, lib, ... }:
with lib;

let cfg = config.tc.haskell.stack;
in
{
  options.tc.haskell.stack = {
    enable = mkEnableOption "stack";
  };

  config = mkIf (cfg.enable) {
    home.packages = with pkgs; [
      stack
    ];

    programs.zsh.shellAliases = {
      swt = "stack build --fast --file-watch --test";
    };

    programs.zsh.oh-my-zsh.plugins = [ "stack" ];
  };
}
