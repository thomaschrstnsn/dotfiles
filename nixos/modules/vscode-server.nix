{ pkgs, config, lib, ... }:
with lib;

let cfg = config.tc.vscode-server;
in
{
  options.tc.vscode-server = with types; {
    enable = mkOption {
      type = bool;
      default = false;
      description = "enable vscode-server";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      nixpkgs-fmt
      nodejs-16_x # server dep
      rnix-lsp # language server
      ripgrep # server dep
      shellcheck
    ];

    services.vscode-server.enable = true;
  };
}
