{
  description = "User Config";
  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.*.tar.gz";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";

    home-manager = {
      url = "https://flakehub.com/f/nix-community/home-manager/0.1.*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "https://flakehub.com/f/ryantm/agenix/0.14.*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware = {
      url = "https://flakehub.com/f/NixOS/nixos-hardware/0.1.*.tar.gz";
    };

    LazyVim = {
      url = "github:matadaniel/LazyVim-module";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ghostty = {
      url = "github:ghostty-org/ghostty";
    };

    hyprpanel = {
      url = "github:Jas-SinghFSU/HyprPanel";
    };

    starship-jj = {
      url = "gitlab:lanastara_foss/starship-jj";
    };

    nixpkgs-python.url = "github:cachix/nixpkgs-python";
    pyenv-nix-install.url = "github:sirno/pyenv-nix-install";

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs
    , home-manager
    , darwin
    , nixos-wsl
    , hyprpanel
    , pyenv-nix-install
    , zen-browser
    , ...
    }@inputs:
    let
      inherit (nixpkgs) lib;

      insecure = [
      ];

      mkIfList = cond: xs: if cond then xs else [ ];

      mkDarwinSystem =
        { extraModules ? [ ]
        , system
        , config ? { }
        , homeManagerConfig ? { }
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
              nixpkgs.config.permittedInsecurePackages = insecure;
            }

            {
              nix = {
                registry.nixpkgs.flake = inputs.nixpkgs;

                nixPath = [
                  "nixpkgs=${inputs.nixpkgs.outPath}"
                ];
              };
            }
            ./base/nix.nix
            ./darwin/modules/bootstrap.nix

            {
              options.tc.user.homedir = lib.mkOption {
                type = lib.types.path;
                description = "home directory";
              };
              options.tc.user.name = lib.mkOption {
                type = lib.types.str;
                description = "username";
              };
            }

            home-manager.darwinModules.home-manager
            {
              home-manager = {
                users."${config.user.name}" = homeManagerConfig;
                useGlobalPkgs = true;
                useUserPackages = true;
              };
            }
            {
              system.primaryUser = config.user.name;
            }

            ./darwin/services
            ./darwin/modules
          ] ++ extraModules;
        };

      mkNixosSystem =
        { base ? { }
        , extraModules
        , system
        , config ? { }
        , homeManagerConfigs ? [ ]
        }:
        let
          inherit (pkgsAndOverlaysForSystem system) pkgs overlays;
        in
        lib.nixosSystem {
          inherit system;
          specialArgs = inputs;
          modules = [
            { config.tc = config; }
            {
              nixpkgs.overlays = overlays;
              nixpkgs.config.allowUnfree = true;
              nixpkgs.config.permittedInsecurePackages = insecure;
            }

            inputs.home-manager.nixosModules.home-manager
            inputs.agenix.nixosModules.default

            {
              nix = {

                registry.nixpkgs.flake = inputs.nixpkgs;

                nixPath = [
                  "nixpkgs=${inputs.nixpkgs.outPath}"
                ];
                # Use the modern optimise setting instead of auto-optimise-store
                optimise.automatic = true;
              };
            }

            ./base/nix.nix
            ./nixos/modules/bootstrap.nix

            {
              home-manager = {
                users = homeManagerConfigs;
                useGlobalPkgs = true;
                useUserPackages = true;
              };
            }

            ./nixos/services
            ./nixos/modules

            base
          ] ++ extraModules;
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
              home =
                {
                  stateVersion = version;
                  username = username;
                  packages = extraPackages pkgs;
                };
            }
            inputs.LazyVim.homeManagerModules.default
            ./home/modules
          ];
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
            inherit pkgs nixpkgs system inputs;
          }) myPkgs;
          inherit (import ./overlays {
            inherit system pkgs lib myPkgs hyprpanel;
          }) overlays;

          pkgs = import nixpkgs {
            inherit system overlays;
            config.allowUnfree = true;

            # https://github.com/NixOS/nixpkgs/issues/341683
            config.permittedInsecurePackages = insecure;
          };
        in
        { inherit pkgs overlays; };

      machineToHome =
        (machine:
          { home ? [ ]
          , extraPackages ? _: [ ]
          , system
          , ...
          }:
          let
            homeConfig = assertOnlyOneHomeConfiguration home;
          in
          {
            "${builtins.replaceStrings ["."] ["_"] homeConfig.user.username}" = mkHMUser {
              homeConfig = homeConfig;
              extraPackages = extraPackages;
              system = system;
            };
          }
        );

      assertOnlyOneHomeConfiguration = home:
        if home == [ ] then
          throw "expected exactly one home configuration, found none"
        else if builtins.tail home != [ ] then
          throw "expected exactly one home configuration, found ${builtins.length home}"
        else
          builtins.head home;

      machineToDarwin =
        (machine:
          { system
          , darwin ? { }
          , home ? [ ]
          , extraPackages ? _: [ ]
          , ...
          }:
          let
            homeConfig = assertOnlyOneHomeConfiguration home;
            fixedUser = homeConfig.user // {
              homedir = null;
            };
            hmConfig = mkHMUser' {
              homeConfig = homeConfig // {
                user = fixedUser;
              };
              extraPackages = extraPackages;
              system = system;
            };
          in
          mkDarwinSystem {
            system = system;
            config = darwin // {
              user.name = homeConfig.user.username;
              user.homedir = homeConfig.user.homedir;
            };
            homeManagerConfig = { imports = hmConfig.modules; manual.manpages.enable = false; };
          }
        );

      machineToNixos =
        (machine:
          { system
          , nixos
          , home ? [ ]
          , extraPackages ? _: [ ]
          , ...
          }:
          let
            # set/dict with keys that are user names, values are homemanager configs
            homeCfgs = builtins.listToAttrs (map
              (hc: {
                name = hc.user.username;
                value = {
                  imports = (mkHMUser' {
                    homeConfig = hc;
                    extraPackages = extraPackages;
                    system = system;
                  }).modules;
                  manual.manpages.enable = false;
                };
              })
              home);
          in
          mkNixosSystem {
            system = system;
            config = nixos.config;
            base = nixos.base;
            extraModules = lib.concatLists [
              (mkIfList (lib.attrsets.attrByPath [ "isWsl" ] false nixos) [ nixos-wsl.nixosModules.default ])
              (mkIfList (lib.attrsets.attrByPath [ "determinateNix" ] true nixos) [ inputs.determinate.nixosModules.default ])
            ];
            homeManagerConfigs = homeCfgs;
          }
        );

      inherit (import ./machines { inherit inputs lib; })
        machines;

      mapAttrWhenHasAttr = f: musthave: attr:
        builtins.mapAttrs f (lib.filterAttrs (n: v: builtins.hasAttr musthave v) attr);
    in
    {
      homeManagerConfigurations =
        mapAttrWhenHasAttr machineToHome "home" machines;

      darwinConfigurations =
        mapAttrWhenHasAttr machineToDarwin "darwin" machines;

      nixosConfigurations =
        mapAttrWhenHasAttr machineToNixos "nixos" machines;
    };
}
