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
        arm-linux = "aarch64-linux";
        x64-linux = "x86_64-linux";
        m1_darwin = "aarch64-darwin";
        x64-darwin = "x86_64-darwin";
      };

      mkDarwinSystem =
        { extraModules ? [ ]
        , system
        , config ? { }
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
            ./modules/darwin
          ] ++ extraModules ++ [{ config.tc = config; }];
        };

      mkHMUser =
        { homeConfig
        , extraPackages ? _: [ ]
        , system
        }:
        let
          version = "21.11";
          inherit (homeConfig.user) homedir username;
          inherit (pkgsAndOverlaysForSystem system) pkgs overlays;
        in
        (
          home-manager.lib.homeManagerConfiguration {
            inherit system username pkgs;
            stateVersion = version;
            configuration = {
              tc = homeConfig;

              nixpkgs.overlays = overlays;
              nixpkgs.config.allowUnfree = true;

              home.stateVersion = version;

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
        in
        { inherit pkgs overlays; };

      machineToHome =
        (machine:
          { home ? null
          , extraPackages ? _: [ ]
          , system
          , ...
          }:
          {
            "${builtins.replaceStrings ["."] ["_"] home.user.username}" = mkHMUser {
              homeConfig = home;
              extraPackages = extraPackages;
              system = system;
            };
          }
        );

      machineToDarwin =
        (machine:
          { system
          , darwin ? { }
          , ...
          }: mkDarwinSystem {
            system = system;
            config = darwin;
          }
        );

      # MACHINE CONFIGURATIONS

      machines = {
        aeris = {
          home = {
            user = rec {
              username = "thomas";
              homedir = "/Users/${username}";
            };
            dotnet.enable = true;
            git.enable = true;
            haskell.stack.enable = true;
            haskell.ihp.enable = true;
            zsh = {
              enable = true;
            };
          };

          darwin = {
            skhd.enable = true;
            spacebar.enable = true;
            yabai.enable = true;
          };

          extraPackages = pkgs: with pkgs; [
            shellcheck
            rnix-lsp
            nixpkgs-fmt
          ];

          system = systems.x64-darwin; # actually m1
        };

        A125228-DK = {
          home = rec {
            user = rec {
              username = "thomas.christensen@schibsted.com";
              homedir = "/Users/${username}";
            };
            aws.enable = true;
            dotnet.enable = true;
            git = {
              enable = true;
              userEmail = user.username;
              githubs = [ "github.com" "github.schibsted.io" ];
            };
            zsh = {
              enable = true;
              skhd = true;
            };
            nodejs = {
              enable = true;
              pkg = pkgs: pkgs.nodejs-14_x;
            };
          };

          darwin = {
            skhd.enable = true;
            spacebar.enable = true;
            yabai.enable = true;
          };

          system = systems.x64-darwin;
        };

        DESKTOP-IP1G00V = {
          home = {
            user = {
              username = "nixos";
              homedir = "/home/nixos";
            };
            aws.enable = false;
            dotnet.enable = false;
            git.enable = true;
            haskell.stack.enable = false;
            haskell.ihp.enable = false;
            zsh = {
              enable = true;
              editor = "vim";
            };
          };
          system = systems.x64-linux;
        };

        nixos-raspi-4 = {
          home = {
            user = {
              username = "pi";
              homedir = "/home/pi";
            };
            git.enable = true;
            zsh = {
              enable = true;
              editor = "vim";
            };
            tmux.enable = true;
          };
          system = systems.arm-linux;
        };

        # Minimal configuration to bootstrap darwin systems
        bootstrap = {
          system = systems.x64-darwin;
        };
      };
    in
    rec {
      homeManagerConfigurations =
        builtins.mapAttrs machineToHome machines;

      darwinConfigurations =
        builtins.mapAttrs machineToDarwin machines;
    };
}
