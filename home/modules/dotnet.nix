{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.dotnet;

  lookup = with pkgs; (with dotnetCorePackages; {
    "2.2" = myPkgs.dotnet.sdk_2_2;
    "3.1" = myPkgs.dotnet.sdk_3_1;
    "6.0" = myPkgs.dotnet.sdk_6_0;
  });

  # https://github.com/NixOS/nixpkgs/blob/master/pkgs/development/compilers/dotnet/default.nix
  combinedDotnet = with pkgs; with dotnetCorePackages;
    combinePackages (map (sdk: getAttr sdk lookup) cfg.sdks);
in
{
  options.tc.dotnet = {
    enable = mkEnableOption "dotnet dev env";

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

    programs.zsh.oh-my-zsh.plugins = [ "dotnet" ];

    programs.git.ignores = [ "consul-settings-backup.json" ];

    programs.zsh.shellAliases = {
      rider = "open -a Rider";
      r = "rider $(fd --type f --glob '*.{sln,??proj}' | fzf)";
    };

    programs.zsh.initExtra = ''
      export PATH=$PATH:~/.dotnet/tools

      _fzf_complete_rider() {
        _fzf_complete --multi --reverse -- "$@" < <(
          fd --type f --glob '*.{sln,??proj}'
        )
      }

      export ASPNETCORE_MSSQL__USERID="sa"
      export ASPNETCORE_MSSQL__PASSWORD="***REMOVED***"
      export ASPNETCORE_MSSQL__DATASOURCE="localhost"

      export SERVICE_TEST_HTTP_HOST="localhost"
      export SERVICE_TEST_HTTP_SCHEME="https"

      export ASPNETCORE_ENVIRONMENT="Development"
      export DOTNET_ROOT="${combinedDotnet}"
      export DOTNET_HOST_PATH="${combinedDotnet}"
    '';
  };
}
