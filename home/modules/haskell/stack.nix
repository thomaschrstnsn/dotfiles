{ pkgs, config, lib, ... }:
with lib;

let cfg = config.tc.haskell.stack;
in {
  options.tc.haskell.stack = {
    enable = mkOption {
      description = "Enable stack";
      type = types.bool;
      default = false;
    };
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
