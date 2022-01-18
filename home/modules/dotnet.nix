{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.dotnet;

  lookup = with pkgs; (with dotnetCorePackages; {
    "2.2" = myPkgs.dotnet.sdk_2_2;
    "3.1" = sdk_3_1;
    "6.0" = myPkgs.dotnet.sdk_6_0;
  });

  # https://github.com/NixOS/nixpkgs/blob/master/pkgs/development/compilers/dotnet/default.nix
  combinedDotnet = with pkgs; with dotnetCorePackages;
    combinePackages (map (sdk: getAttr sdk lookup) cfg.sdks);
in
{
  options.tc.dotnet = {
    enable = mkEnableOption "dotnet core dev env";

    sdks = mkOption {
      description = "Which dotnet sdks to install";
      type = types.listOf types.str;
      default = [ "6.0" ];
    };
  };

  config = mkIf (cfg.enable) {
    home.packages = [
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

      _fzf_complete_rider() {
        _fzf_complete --multi --reverse -- "$@" < <(
          fd --type f --glob '*.{sln,??proj}'
        )
      }

    '';
  };
}
