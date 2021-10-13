{
  description = "System Config";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-21.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-21.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }@inputs:
    let
      inherit (nixpkgs) lib;

      util = import ./lib {
        inherit system pkgs home-manager lib;
      };

      scripts = import ./scripts {
        inherit pkgs lib;
      };

      inherit (import ./pkgs {
        inherit pkgs;
      }) myPkgs;

      inherit (util) user;
      inherit (util) host;

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      # system = "x86_64-linux";
      system = "x86_64-darwin";
    in
    {
      homeManagerConfigurations = {
        aeris.thomas = user.mkHMUser {
          userConfig = {
            git.enable = true;
            zsh.enable = true;
            haskell.stack.enable = true;
            aws.enable = false;
          };
          username = "thomas";
          homedir = "/Users/thomas";
        };
      };
    };
}
