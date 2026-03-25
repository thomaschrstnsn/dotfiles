{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.dotnet;

  lookup = with pkgs; (with dotnetCorePackages; {
    "7.0" = sdk_7_0;
    "8.0" = sdk_8_0;
    "9.0" = sdk_9_0;
    "10.0" = sdk_10_0;
  });

  # https://github.com/NixOS/nixpkgs/blob/master/pkgs/development/compilers/dotnet/default.nix
  combinedDotnet = mkIf (cfg.sdks != [ ]) (with pkgs; with dotnetCorePackages;
    combinePackages (map (sdk: getAttr sdk lookup) cfg.sdks));
in
{
  options.tc.dotnet = {
    enable = mkEnableOption "dotnet dev env";

    sdks = mkOption {
      description = "Which dotnet sdks to install";
      type = types.listOf types.str;
      default = [ "8.0" ];
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      combinedDotnet
      fd
    ];
    programs = {
      zsh = {
        oh-my-zsh.plugins = [ "dotnet" ];

        shellAliases = {
          rider = ''open -na "Rider.app" --args "$@"''; # https://www.jetbrains.com/help/rider/Working_with_the_IDE_Features_from_Command_Line.html#10c968a9
          r = "rider $(fd --type f --glob '*.{sln,??proj}' | fzf)";
        };

        initContent = ''
          export PATH=$PATH:~/.dotnet/tools

          _fzf_complete_rider() {
            _fzf_complete --multi --reverse -- "$@" < <(
              fd --type f --glob '*.{sln,??proj}'
            )
          }

          export ASPNETCORE_ENVIRONMENT="Development"
        '' + (if cfg.sdks != [ ] then ''
          # https://discourse.nixos.org/t/dotnet-maui-workload/20370/24
          export DOTNET_PATH="${combinedDotnet}/bin/dotnet"
          export DOTNET_ROOT="${combinedDotnet}/share/dotnet"
        '' else ''
          export PATH=/usr/local/share/dotnet:$PATH
        '');
      };
      fish = {
        shellAliases = {
          rider = ''open -na "Rider.app" --args $args''; # https://www.jetbrains.com/help/rider/Working_with_the_IDE_Features_from_Command_Line.html#10c968a9
          r = "rider $(fd --type f --glob '*.{sln,??proj}' | fzf)";
        };

        interactiveShellInit = ''
          set PATH $PATH ~/.dotnet/tools

          set ASPNETCORE_ENVIRONMENT Development

        '' + (if cfg.sdks != [ ] then ''
          # https://discourse.nixos.org/t/dotnet-maui-workload/20370/24
          set DOTNET_PATH "${combinedDotnet}/bin/dotnet"
          set DOTNET_ROOT "${combinedDotnet}/share/dotnet"
        '' else ''
          fish_add_path /usr/local/share/dotnet
        '');
      };
    };
  };
}
