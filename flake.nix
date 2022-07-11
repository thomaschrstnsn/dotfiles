{
  description = "User Config";
  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";

    # nixos-stable.url = "nixpkgs/nixos-stable";
    # nixos-unstable.url = "nixpkgs/nixos-unstable";

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

    nixos-vscode-server = {
      url = "github:msteen/nixos-vscode-server";
      flake = false;
    };
  };

  outputs = { nixpkgs, home-manager, darwin, forgit-git, nixos-vscode-server, ... }@inputs:
    let
      inherit (nixpkgs) lib;

      mkDarwinSystem =
        { extraModules ? [ ]
        , system
        , config ? { }
        }:
        let
          inherit (pkgsAndOverlaysForSystem system) pkgs overlays;
        in
        darwin.lib.darwinSystem {
          inherit system;
          modules = [
            {
              nixpkgs.overlays = overlays;
            }
            ./darwin/modules/bootstrap.nix
            ./darwin/services
            ./darwin/modules
          ] ++ extraModules ++ [{ config.tc = config; }];
        };

      mkNixosSystem =
        { base ? { }
        , system
        , config ? { }
        , home-manager-config ? { }
        }:
        let
          inherit (pkgsAndOverlaysForSystem system) pkgs overlays;
        in
        lib.nixosSystem {
          inherit system;
          modules = [
            { config.tc = config; }
            { nixpkgs.overlays = overlays; }

            inputs.home-manager.nixosModules.home-manager

            ./nixos/modules/bootstrap.nix

            {
              home-manager = {
                users."${config.user.name}" = home-manager-config;
                useGlobalPkgs = true;
                useUserPackages = true;
              };
            }

            ./nixos/services
            ./nixos/modules

            base
          ];
        };

      mkHMUser' =
        { homeConfig
        , extraPackages ? _: [ ]
        , system
        }:
        let
          version = "21.11";
          inherit (homeConfig.user) homedir username;
          inherit (pkgsAndOverlaysForSystem system) pkgs overlays;
        in
        {
          inherit pkgs;
          modules = [
            {
              tc = homeConfig;
              home = {
                homeDirectory = homedir;
                stateVersion = version;
                packages = extraPackages pkgs;
              };
            }
            ./home/modules
          ] ++
          (if (pkgs.stdenv.isLinux)
          then [
            "${nixos-vscode-server}/modules/vscode-server/home.nix"
            ./home/modules/vscode-server.nix
          ]
          else
            [ ]);
        };

      mkHMUser =
        { homeConfig
        , extraPackages ? _: [ ]
        , system
        }:
        home-manager.lib.homeManagerConfiguration
          (mkHMUser' { inherit homeConfig extraPackages system; });

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

      machineToNixos =
        (machine:
          { system
          , nixos ? { config = { }; base = { }; }
          , home ? null
          , extraPackages ? _: [ ]
          , ...
          }:
          let
            homeCfg = mkHMUser' {
              homeConfig = home;
              extraPackages = extraPackages;
              system = system;
            };
          in
          mkNixosSystem {
            system = system;
            config = nixos.config // { user.name = home.user.username; };
            base = nixos.base;
            home-manager-config = { imports = homeCfg.modules; };
          }
        );

      inherit (import ./machines.nix)
        machines;
    in
    rec {
      homeManagerConfigurations =
        builtins.mapAttrs machineToHome machines;

      darwinConfigurations =
        builtins.mapAttrs machineToDarwin machines;

      nixosConfigurations =
        builtins.mapAttrs machineToNixos machines;
    };
}
