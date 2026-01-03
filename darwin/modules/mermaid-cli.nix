{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.tc.mermaidCli;
in
{
  options.tc.mermaidCli = with types; {
    enable = mkEnableOption "mermaid-cli with chrome for aarch64";
  };
  config = mkIf cfg.enable {
    homebrew = {
      enable = true;
      casks = [
        "google-chrome"
      ];
    };
    environment.systemPackages = with pkgs; [
      (writeShellScriptBin "mmdc" ''
        ${nodePackages.mermaid-cli}/bin/mmdc \
          --puppeteerConfigFile ${writeText "puppeteer-config.json" ''
            {
              "executablePath": "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
            }
          ''} \
          "$@"
      '')
    ];
  };
}
