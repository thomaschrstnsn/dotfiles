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

      mkDarwinSystem = 
        { extraModules ? []
        , system
        }: 
        darwin.lib.darwinSystem {
          inherit system;
          modules = [
            ./modules/darwin/bootstrap.nix
            ] ++ extraModules;
      };

      mkHMUser = 
        { userConfig
        , username
        , homedir
        }:
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

              imports = [ ./modules/users ];
            };
          homeDirectory = homedir;
        }
      );

      inherit (import ./pkgs {
        inherit pkgs forgit-git;
      }) myPkgs;

      inherit (import ./overlays {
        inherit system pkgs lib myPkgs;
      }) overlays;

      pkgs = import nixpkgs {
        inherit system overlays;
        config.allowUnfree = true;
      };
    in
    rec {
      homeManagerConfigurations = {
        aeris.thomas = mkHMUser {
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
        A125228-DK."thomas_christensen@schibsted_com" = mkHMUser {
          userConfig = {
            aws.enable = true;
            dotnet.enable = true;
            git = {
              enable = true;
              userEmail = "thomas.christensen@schibsted.com";
              githubs = ["github.com" "github.schibsted.io"];
            };
            haskell.stack.enable = true;
            haskell.ihp.enable = true;
            zsh.enable = true;
          };
          username = "thomas.christensen@schibsted.com";
          homedir = "/Users/thomas.christensen@schibsted.com";
        };
        nixos.nixos = mkHMUser {
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
         # Minimal configuration to bootstrap systems
        bootstrap = mkDarwinSystem {
          system = "x86_64-darwin";
        };

        aeris = mkDarwinSystem {
          system = "x86_64-darwin";
          extraModules = [
            ./modules/darwin/osx.nix
            ./modules/darwin/skhd.nix
            ];
        }; 
      };
    };
}
