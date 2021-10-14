{
  description = "User Config";
  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    forgit-git = {
      url = github:wfxr/forgit;
      flake = false;
    };
  };

  outputs = { nixpkgs, home-manager, darwin, forgit-git, ... }@inputs:
    let
      inherit (nixpkgs) lib;

      # system = "x86_64-linux";
      # system = "aarch64-darwin";
      system = "x86_64-darwin";

      util = import ./lib {
        inherit system pkgs home-manager lib; inherit overlays;
      };

      inherit (import ./pkgs {
        inherit pkgs forgit-git;
      }) myPkgs;

      inherit (import ./overlays {
        inherit system pkgs lib myPkgs;
      }) overlays;

      inherit (util) user;

      pkgs = import nixpkgs {
        inherit system overlays;
        config.allowUnfree = true;
      };
    in
    {
      homeManagerConfigurations = {
        aeris.thomas = user.mkHMUser {
          userConfig = {
            aws.enable = true;
            dotnet.enable = true;
            git.enable = true;
            haskell.stack.enable = true;
            haskell.ihp.enable = true;
            zsh.enable = true;
          };
          username = "thomas";
          homedir = "/Users/thomas";
        };
        nixos.nixos = user.mkHMUser {
          userConfig = {
            aws.enable = false;
            dotnet.enable = false;
            git.enable = true;
            haskell.stack.enable = false;
            haskell.ihp.enable = false;
            zsh.enable = true;
          };
          username = "nixos";
          homedir = "/home/nixos";
        };
      };

      darwinConfigurations = {
        aeris = darwin.lib.darwinSystem  {
          inherit system;
          modules = [ ./darwin/configuration.nix ];
          specialArgs = { inherit inputs nixpkgs; };
        };
      };
    };
}
