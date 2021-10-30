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

    spacebar = {
      url = "github:cmacrae/spacebar/v1.3.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, darwin, forgit-git, spacebar, ... }@inputs:
    let
      inherit (nixpkgs) lib;

      systems = {
        arm-linux  = "aarch64-linux";
        x64-linux  = "x86_64-linux";
        m1_darwin  = "aarch64-darwin";
        x64-darwin = "x86_64-darwin";
      };

      mkDarwinSystem = 
        { extraModules ? []
        , system
        }: 
        darwin.lib.darwinSystem {
          inherit system;
          modules = [
            {
              nixpkgs.overlays = [
                spacebar.overlay
              ];
            }
            ./modules/darwin/bootstrap.nix
            ] ++ extraModules;
      };

      mkHMUser = 
        { userConfig
        , username
        , homedir
        , system
        , extraPackages ? _ : []
        }:
      let
        version = "21.11";
        inherit (pkgsAndOverlaysForSystem system) pkgs overlays;
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

              home.packages = extraPackages pkgs;

              imports = [ ./modules/users ];
            };
          homeDirectory = homedir;
        }
      );

      pkgsAndOverlaysForSystem = system: 
      let 
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
      in {inherit pkgs overlays;};
    in
    rec {
      homeManagerConfigurations = {
        aeris.thomas = mkHMUser {
          userConfig = {
            dotnet.enable = true;
            git.enable = true;
            haskell.stack.enable = true;
            haskell.ihp.enable = true;
            zsh = {
              enable = true;
              skhd = true;
            };
          };
          username = "thomas";
          homedir = "/Users/thomas";
          system = systems.x64-darwin; # actually m1
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
            zsh = {
              enable = true;
              skhd = true;
            };
            nodejs = {
              enable = true;
              pkg = pkgs : pkgs.nodejs-14_x;
            };
          };
          username = "thomas.christensen@schibsted.com";
          homedir = "/Users/thomas.christensen@schibsted.com";
          system = systems.x64-darwin;
          # extraPackages = pkgs: with pkgs; [
          #   nodejs-14_x
          # ];
        };
        DESKTOP-IP1G00V.nixos = mkHMUser {
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
          system = systems.x64-linux;
        };
      };

      darwinConfigurations = {
         # Minimal configuration to bootstrap systems
        bootstrap = mkDarwinSystem {
          system = systems.x64-darwin;
        };

        aeris = mkDarwinSystem {
          system = systems.x64-darwin; # actually m1
          extraModules = [
            ./modules/darwin/osx.nix
            ./modules/darwin/skhd.nix
            ./modules/darwin/yabai.nix
            ./modules/darwin/spacebar.nix
            ];
        }; 

        A125228-DK = mkDarwinSystem {
          system = systems.x64-darwin;
          extraModules = [
            ./modules/darwin/osx.nix
            ./modules/darwin/skhd.nix
            ./modules/darwin/yabai.nix
            ./modules/darwin/spacebar.nix
            ];
        }; 
      };
    };
}
