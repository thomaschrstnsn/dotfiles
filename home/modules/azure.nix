{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.azure;
in
{
  options.tc.azure = {
    enable = mkEnableOption "azure (cli)";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      (azure-cli.withExtensions (with azure-cli.extensions; [ ssh ]))
    ];
  };
}
