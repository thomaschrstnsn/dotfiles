{ pkgs, home-manager, lib, system, ... }:
with builtins;
{
  mkHMUser = {userConfig, username, homedir}:
    let
      version = "21.05";
    in (
      home-manager.lib.homeManagerConfiguration {
        inherit system username pkgs;
        stateVersion = version;
        configuration =
          let
            x = "y";
          
          in {
            tc = userConfig;

            # nixpkgs.overlays = overlays;
            nixpkgs.config.allowUnfree = true;

            # systemd.user.startServices = true;
            home.stateVersion = version;
            home.username = username;
            home.homeDirectory = homedir;

            imports = [ ../modules/users ];
          };
        homeDirectory = homedir;
      }
    );
}
