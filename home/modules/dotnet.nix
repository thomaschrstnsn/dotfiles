{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.dotnet;

  lookup = with pkgs; (with dotnetCorePackages; {
    "6.0" = myPkgs.dotnet.sdk_6_0;
    "7.0" = myPkgs.dotnet.sdk_7_0;
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

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      combinedDotnet
      fd
    ];

    programs.zsh.oh-my-zsh.plugins = [ "dotnet" ];

    programs.git.ignores = [ "consul-settings-backup.json" ];

    programs.zsh.shellAliases = {
      # rider = "open -a Rider"; # there should be script in in /usr/local/bin/rider from the toolbox: https://www.jetbrains.com/help/rider/Working_with_the_IDE_Features_from_Command_Line.html#10c968a9
      r = "rider $(fd --type f --glob '*.{sln,??proj}' | fzf)";
    };

    programs.zsh.initExtra = ''
      export PATH=$PATH:~/.dotnet/tools

      _fzf_complete_rider() {
        _fzf_complete --multi --reverse -- "$@" < <(
          fd --type f --glob '*.{sln,??proj}'
        )
      }

      export ASPNETCORE_ENVIRONMENT="Development"
      export DOTNET_ROOT="${combinedDotnet}"
      export DOTNET_HOST_PATH="${combinedDotnet}/dotnet"
    '';
  };
}
