{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.wsl;
in
{
  options.tc.wsl = with types; {
    enable = mkEnableOption "wsl";
  };

  config = mkIf cfg.enable {
    # wslu was discontinued and removed from nixpkgs (2026-04-08)
    home.packages = with pkgs; [
      wsl-open
    ];

    programs.zsh.initContent = ''
      export PATH=/mnt/c/Windows/System32:/mnt/c/Windows/System32/WindowsPowerShell/v1.0:$PATH
    '';
  };
}
