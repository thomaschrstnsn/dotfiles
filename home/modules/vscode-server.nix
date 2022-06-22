{ pkgs, config, lib, ... }:
with lib;

let cfg = config.tc.vscode-server;
in
{
  options.tc.vscode-server = {
    enable = mkEnableOption "vscode-server";
  };

  config = mkIf (cfg.enable) {
    home.packages = with pkgs; [
      nixpkgs-fmt
      nodejs-16_x # server dep
      rnix-lsp # language server
      ripgrep # server dep
      shellcheck
    ];

    services.vscode-server.enable = true;
  };
}
