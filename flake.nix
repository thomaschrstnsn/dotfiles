{
  description = "User Config";
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

      # system = "x86_64-linux";
      # system = "aarch64-darwin";
      system = "x86_64-darwin";

      util = import ./lib {
        inherit system pkgs home-manager lib;
      };

      inherit (util) user;

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      homeManagerConfigurations = {
        aeris.thomas = user.mkHMUser {
          userConfig = {
            git.enable = true;
            zsh.enable = true;
            haskell.stack.enable = true;
            haskell.ihp.enable = true;
            aws.enable = false;
          };
          username = "thomas";
          homedir = "/Users/thomas";
        };
      };
    };
}
