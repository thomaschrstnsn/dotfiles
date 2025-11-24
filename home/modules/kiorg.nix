{ pkgs, config, lib, ... }:
with lib;

let
  cfg = config.tc.kiorg;

  kiorg = pkgs.rustPlatform.buildRustPackage rec {
    pname = "kiorg";
    version = "0.3.0";
    src = pkgs.fetchFromGitHub {
      owner = "houqp";
      repo = "kiorg";
      rev = "v1.2.3";
      hash = "sha256-RnRppxw2VtMqIPqSUkSHbs3N9vn+kx/oKB63W3tYyFs";
    };
    cargoHash = "sha256-5PQ9SLy8w35Yu+0Y3ccdIdyYHOqdkL37z2ZU0wqjsqI";
  };
in
{
  options.tc.kiorg = {
    enable = mkEnableOption "kiorg";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      kiorg
    ];
  };
}

