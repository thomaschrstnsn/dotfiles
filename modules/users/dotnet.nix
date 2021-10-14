{ pkgs, config, lib, ... }:
with lib;

let 
  cfg = config.tc.dotnet;
in {
  options.tc.dotnet = {
    enable = mkOption {
      description = "Enable dotnet core dev env";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf (cfg.enable) {
    home.packages = with pkgs; [
      dotnet-sdk_3
    ];

    programs.zsh.sessionVariables = {
      ASPNETCORE_MSSQL__USERID = "sa";
      ASPNETCORE_MSSQL__PASSWORD = "***REMOVED***";
      ASPNETCORE_MSSQL__DATASOURCE = "localhost";

      SERVICE_TEST_HTTP_HOST = "localhost";
      SERVICE_TEST_HTTP_SCHEME = "https";

      ASPNETCORE_ENVIRONMENT = "Development";
    };

    programs.zsh.oh-my-zsh.plugins = [ "dotnet" ];
  };
}
