{
  description = "User Config";
  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.*.tar.gz";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";

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

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wezterm = {
      url = "github:wez/wezterm?dir=nix";
    };

    hyprpanel = {
      url = "github:Jas-SinghFSU/HyprPanel";
    };

    starship-jj = {
      url = "gitlab:lanastara_foss/starship-jj";
    };

    nixpkgs-python.url = "github:cachix/nixpkgs-python";
    pyenv-nix-install.url = "github:sirno/pyenv-nix-install";

    zen-browser.url = "github:0xc000022070/zen-browser-flake";
  };

  outputs =
    { nixpkgs
    , home-manager
    , darwin
    , nixvim
    , nixos-wsl
    , wezterm
    , hyprpanel
    , pyenv-nix-install
    , zen-browser
    , ...
    }@inputs:
    let
      inherit (nixpkgs) lib;

      insecure = [
        # "electron-27.3.11"
        "dotnet-sdk-6.0.428"
        "dotnet-sdk-7.0.410"
      ];

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
        , extra-modules
        , system
        , config ? { }
        , home-manager-config ? { }
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
              };
            }

            ./base/nix.nix
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
          ] ++ extra-modules;
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
              home =
                {
                  stateVersion = version;
                  username = username;
                  packages = extraPackages pkgs;
                };
            }
            nixvim.homeManagerModules.nixvim
            {
              # this module seems to be needed when we disable nixvim, otherwise we have an error:
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
            config = darwin // {
              user.name = home.user.username;
              user.homedir = home.user.homedir;
            };
            home-manager-config = { imports = hm-config.modules; manual.manpages.enable = false; };
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
            extra-modules = if (lib.attrsets.attrByPath [ "isWsl" ] false nixos) then [ nixos-wsl.nixosModules.default ] else [ ];
            home-manager-config = { imports = homeCfg.modules; manual.manpages.enable = false; };
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
