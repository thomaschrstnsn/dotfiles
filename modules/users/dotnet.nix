{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.dotnet;

  combinedDotnet = with pkgs;
    (with dotnetCorePackages; combinePackages [
      sdk_3_1
      myPkgs.dotnet.sdk_6_0
      myPkgs.dotnet.sdk_2_2
    ]);
in
{
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
      combinedDotnet
    ];

    programs.zsh.sessionVariables = {
      ASPNETCORE_MSSQL__USERID = "sa";
      ASPNETCORE_MSSQL__PASSWORD = "***REMOVED***";
      ASPNETCORE_MSSQL__DATASOURCE = "localhost";

      SERVICE_TEST_HTTP_HOST = "localhost";
      SERVICE_TEST_HTTP_SCHEME = "https";

      ASPNETCORE_ENVIRONMENT = "Development";
      DOTNET_ROOT = "${combinedDotnet}";
    };

    programs.zsh.oh-my-zsh.plugins = [ "dotnet" ];

    programs.git.ignores = [ "consul-settings-backup.json" ];

    programs.zsh.shellAliases = {
      rider = "open -a Rider";
    };

    programs.zsh.initExtra = ''
      export PATH=$PATH:~/.dotnet/tools
    '';
  };
}
