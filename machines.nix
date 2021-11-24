let
  systems = {
    arm-linux = "aarch64-linux";
    x64-linux = "x86_64-linux";
    m1_darwin = "aarch64-darwin";
    x64-darwin = "x86_64-darwin";
  };
in
{
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
          skhd = true;
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
        skhd = {
          enable = true;
          browser = "Microsoft Edge";
          extraAppShortcuts = {
            "hyper - z" = "zoom.us";
            "hyper - c" = "Slack";
            "hyper - r" = "Rider";
          };
        };
        spacebar.enable = true;
        yabai.enable = true;
      };

      extraPackages = pkgs: with pkgs; [
        shellcheck
        rnix-lsp
        nixpkgs-fmt
      ];

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
}
