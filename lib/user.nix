{ pkgs, home-manager, lib, system, overlays, ... }:
with builtins;
{
  mkHMUser = {userConfig, username, homedir}:
    let
      version = "21.11";
    in (
      home-manager.lib.homeManagerConfiguration {
        inherit system username pkgs;
        stateVersion = version;
        configuration = {
            tc = userConfig;

            nixpkgs.overlays = overlays;
            nixpkgs.config.allowUnfree = true;

            home.stateVersion = version;
            home.username = username;
            home.homeDirectory = homedir;

            imports = [ ../modules/users ];
          };
        homeDirectory = homedir;
      }
    );
}
