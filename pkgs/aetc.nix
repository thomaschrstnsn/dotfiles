{ pkgs }:

pkgs.rustPlatform.buildRustPackage  {
          pname = "aero-traffic-control";
          version = "0.1.0";

          src = pkgs.fetchFromGitHub {
            owner = "thomaschrstnsn";
            repo = "aero-traffic-control";
            rev = "794d701ed6056b475a6e513a95464a072367449a";
            hash = "sha256-7bDMBT1HlioCjHP62aUUMPFmuIUfTvlPHJNAujHgHf4";
          };

          cargoHash = "sha256-/73ny4tgx0zX5fEBAiAjRKszhK3P/wehHqGHgU513Yc=";

          meta = with pkgs.lib; {
            description = "A CLI tool for intelligent window management using AeroSpace";
            license = licenses.mit;
            platforms = platforms.darwin;
          };
        }

