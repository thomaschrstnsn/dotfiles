{ lib, inputs, ... }:

let
  systems = {
    arm-linux = "aarch64-linux";
    x64-linux = "x86_64-linux";
    m1-darwin = "aarch64-darwin";
    x64-darwin = "x86_64-darwin";
  };

  nixos-raspi-4 = "nixos-raspi-4";
  vmnix = "vmnix";
  DESKTOP-IP1G00V = "DESKTOP-IP1G00V";

  skhd-scripts = ./darwin/modules/skhd;
in
{
  machines = {
    aeris = {
      home = {
        user = rec {
          username = "thomas";
          homedir = "/Users/${username}";
        };
        dotnet = {
          enable = true;
          sdks = [ "6.0" ];
        };
        git.enable = true;
        haskell.stack.enable = true;
        haskell.ihp.enable = true;
        smd_launcher.enable = true;
        zsh = {
          enable = true;
          skhd = true;
        };
      };

      darwin = {
        homebrew = {
          enable = true;
          extraCasks = [
            "brave-browser"
          ];
        };
        skhd = {
          enable = true;
          browser = "Brave Browser";
          extraAppShortcuts = {
            "hyper - r" = "Rider";
            "hyper - u" = "Inkdrop";
          };
          extraShortcuts = {
            "hyper - 0x0A" = "yabai -m space --toggle show-desktop"; # button left of 1
            "hyper - e" = "yabai -m space --toggle mission-control";
          };
          prefixShortcuts = {
            leadingShortcut = "hyper - 9";
            appShortcuts = {
              c = "Calendar";
            };
          };
        };
        sketchybar = {
          enable = true;
          scale = "laptop";
          position = "top";
        };
        yabai.enable = true;
      };

      extraPackages = pkgs: with pkgs; [
        shellcheck
        rnix-lsp
        nixpkgs-fmt

        cloudflared # for ssh through cloudflare
      ];

      system = systems.m1-darwin;
    };

    A125228-DK = {
      home = rec {
        user = rec {
          username = "thomas.christensen@schibsted.com";
          homedir = "/Users/${username}";
        };
        aws.enable = true;
        dotnet = {
          enable = true;
          sdks = [ "2.2" "3.1" "6.0" ];
        };
        git = {
          enable = true;
          userEmail = user.username;
          githubs = [ "github.schibsted.io" ];
        };
        zsh = {
          enable = true;
          skhd = true;
          extraAliases = {
            meet-billing-and-reporting = ''"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --app=http://g.co/meet/billing-and-reporting &'';
            meet-browser = ''"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --app=http://g.co/meet/ &'';
          };
        };
        smd_launcher.enable = true;
        direnv.enable = true;
        nodejs = {
          enable = true;
          pkg = pkgs: pkgs.nodejs-16_x;
        };
      };

      darwin = {
        homebrew = {
          enable = true;
          extraTaps = [ "Microsoft/homebrew-mssql-release" ];
          extraBrews = [
            "microsoft/mssql-release/mssql-tools" # 🤦‍♂️ first time install, you need to type: "YES" + enter while the prompt: "Installing microsoft/mssql-release/mssql-tools" is present
          ];
          extraCasks = [
            "asana"
            "azure-data-studio"
            "brave-browser"
            "jetbrains-toolbox"
            "meetingbar"
            "microsoft-edge"
            "microsoft-remote-desktop"
          ];
        };
        skhd = {
          enable = true;
          browser = "Microsoft Edge";
          extraAppShortcuts = {
            "hyper - z" = "zoom.us";
            "hyper - c" = "Slack";
            "hyper - r" = "Rider";
            "hyper - v" = "VMWare Fusion";
            "hyper - u" = "Inkdrop";
            "hyper - g" = "Google Chrome";
            "hyper - h" = "Brave Browser";
            "hyper - d" = "Azure Data Studio";
            "hyper - 0x32" = "Asana"; # >/<
          };
          extraShortcuts = {
            "hyper - 0" = "alacritty --working-directory ~/bin -e ~/bin/smd"; # smd-launcher
            "hyper - e" = "yabai -m space --toggle mission-control";
            "hyper - 0x0A" = "yabai -m space --toggle show-desktop"; # button left of 1
            "shift - f14" = "osascript ${skhd-scripts}/toggle-mute-mic.applescript";
            # "cmd + shift - f14" = "say command";
            # "hyper - f14" = "say hyper";
            # "alt + shift - f14" = "say alt";
          };
          prefixShortcuts = {
            leadingShortcut = "hyper - 9";
            appShortcuts = {
              r = "Microsoft Remote Desktop";
            };
            shortcuts = { };
          };
        };
        sketchybar = {
          enable = true;
          scale = "desktop";
          position = "top";
          aliases.appgate.enable = true;
          aliases.meetingbar.enable = true;
        };
        yabai.enable = true;
      };

      extraPackages = pkgs: with pkgs; [
        shellcheck
        rnix-lsp
        nixpkgs-fmt
        ripgrep
      ];

      system = systems.x64-darwin;
    };

    "${DESKTOP-IP1G00V}" =
      let
        username = "nixos";
        configurationRoot = ./nixos/machines/DESKTOP-IP1G00V;
      in
      {
        home = {
          user = {
            username = username;
            homedir = "/home/${username}";
          };
          git.enable = true;
          zsh = {
            enable = true;
            editor = "vim";
          };
          vscode-server.enable = true;
        };
        system = systems.x64-linux;

        nixos = {
          config = {
            user = {
              name = username;
              groups = [ "wheel" ];
            };
            networking.hostname = DESKTOP-IP1G00V;
          };
          base = {
            imports = [
              (configurationRoot + "/configuration.nix")
            ];
          };
        };

      };

    "${nixos-raspi-4}" =
      let
        username = "pi";
        configurationRoot = ./nixos/machines/nixos-raspi-4;
      in
      {
        home = {
          user = {
            username = username;
            homedir = "/home/${username}";
          };
          git.enable = true;
          zsh = {
            enable = true;
            editor = "vim";
          };
          tmux.enable = true;
          vscode-server.enable = true;
        };
        system = systems.arm-linux;

        extraPackages = pkgs: with pkgs; [
        ];

        nixos = {
          config = {
            user = {
              name = username;
              groups = [ "wheel" "docker" ];
            };
            networking.hostname = nixos-raspi-4;
          };
          base = {
            imports = [
              (configurationRoot + "/configuration.nix")
              (configurationRoot + "/cloudflare.nix")

              inputs.nixos-hardware.nixosModules.raspberry-pi-4
            ];

          };
        };
      };

    "${vmnix}" =
      let
        configurationRoot = ./nixos/machines/vmnix;
      in
      {
        home = {
          user = {
            username = "thomas";
            homedir = "/home/thomas";
          };
          git.enable = true;
          zsh = {
            enable = true;
            editor = "vim";
          };
          tmux.enable = true;
          vscode-server.enable = true;
        };
        system = systems.arm-linux;

        nixos = {
          config = {
            networking.hostname = vmnix;
          };
          base = {
            imports =
              [
                (configurationRoot + "/hardware.nix")
                (configurationRoot + "/configuration.nix")
              ];
          };
        };
      };

    # Minimal configuration to bootstrap darwin systems
    darwin-bootstrap-x64 = {
      system = systems.x64-darwin;
    };
    darwin-bootstrap-aarch64 = {
      system = systems.m1-darwin;
    };
  };
}
