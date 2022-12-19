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

    nixos-vscode-server = {
      url = "github:msteen/nixos-vscode-server";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware = {
      url = github:NixOS/nixos-hardware/master;
    };

    nixvim = {
      url = github:pta2002/nixvim;
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, darwin, nixos-vscode-server, nixvim, ... }@inputs:
    let
      inherit (nixpkgs) lib;

      mkDarwinSystem =
        { extraModules ? [ ]
        , system
        , config ? { }
        , home-manager-config ? { }
        }:
        let
          inherit (pkgsAndOverlaysForSystem system) pkgs overlays;
        in
        darwin.lib.darwinSystem {
          inherit system;
          modules = [
            { config.tc = config; }
            {
              nixpkgs.overlays = overlays;
              nixpkgs.config.allowUnfree = true;
            }

            home-manager.darwinModule

            ./base/nix.nix
            ./darwin/modules/bootstrap.nix

            {
              options.tc.user.name = lib.mkOption {
                type = lib.types.str;
                description = "username";
              };
            }

            {
              home-manager = {
                users."${config.user.name}" = home-manager-config;
                useGlobalPkgs = true;
                useUserPackages = true;
              };
            }

            ./darwin/services
            ./darwin/modules
          ] ++ extraModules;
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
            inputs.agenix.nixosModule

            ./base/nix.nix
            ./nixos/modules/bootstrap.nix

            {
              home-manager = {
                users."${config.user.name}" = home-manager-config;
                useGlobalPkgs = true;
                useUserPackages = true;
              };
            }

            nixos-vscode-server.nixosModule

            ./nixos/services
            ./nixos/modules

            base
          ];
        };

      mkHMUser' =
        { homeConfig
        , extraPackages ? _: [ ]
        , system
        , nixvim
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
                stateVersion = version;
                username = username;
                packages = extraPackages pkgs;
              };
            }
            nixvim.homeManagerModules.nixvim
            {
              # this module seems to be needed when we disable nix, otherwise we have an error:
              # error: The option `home-manager.users.someuser.programs.nixvim' is used but not defined.
              config = { programs.nixvim.extraPlugins = [ ]; };
            }
            ./home/modules
          ];
        };

      mkHMUser =
        { homeConfig
        , extraPackages ? _: [ ]
        , system
        }:
        home-manager.lib.homeManagerConfiguration
          (mkHMUser' { inherit homeConfig extraPackages system nixvim; });

      pkgsAndOverlaysForSystem = system:
        let
          inherit (import ./pkgs {
            inherit pkgs nixpkgs;
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
          , home ? null
          , extraPackages ? _: [ ]
          , ...
          }:
          let
            fixedUser = home.user // { homedir = null; };
            hm-config = mkHMUser' {
              homeConfig = home // {
                user = fixedUser;
              };
              extraPackages = extraPackages;
              system = system;
              inherit nixvim;
            };
          in
          mkDarwinSystem {
            system = system;
            config = darwin // { user.name = home.user.username; };
            home-manager-config = { imports = hm-config.modules; };
          }
        );

      machineToNixos =
        (machine:
          { system
          , nixos
          , home ? null
          , extraPackages ? _: [ ]
          , ...
          }:
          let
            homeCfg = mkHMUser' {
              homeConfig = home;
              extraPackages = extraPackages;
              system = system;
              inherit nixvim;
            };
            user = nixos.config.user // { name = home.user.username; };
          in
          mkNixosSystem {
            system = system;
            config = nixos.config // { inherit user; };
            base = nixos.base;
            home-manager-config = { imports = homeCfg.modules; };
          }
        );

      inherit (import ./machines { inherit inputs lib; })
        machines;

      mapAttrWhenHasAttr = f: musthave: attr:
        builtins.mapAttrs f (lib.filterAttrs (n: v: builtins.hasAttr musthave v) attr);
    in
    rec {
      homeManagerConfigurations =
        mapAttrWhenHasAttr machineToHome "home" machines;

      darwinConfigurations =
        mapAttrWhenHasAttr machineToDarwin "darwin" machines;

      nixosConfigurations =
        mapAttrWhenHasAttr machineToNixos "nixos" machines;
    };
}
