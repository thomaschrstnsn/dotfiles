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
    # https://github.com/NixOS/nixpkgs/blob/master/pkgs/development/compilers/dotnet/default.nix
    home.packages = with pkgs; [
      (with dotnetCorePackages; combinePackages [
        sdk_3_1
        sdk_2_1
        myPkgs.dotnet.sdk_2_2
      ])
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
