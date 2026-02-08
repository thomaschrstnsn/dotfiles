{ pkgs, lib }:

let version = "0.0.1";
in
pkgs.rustPlatform.buildRustPackage {
  pname = "screentime-web";
  inherit version;

  src = pkgs.fetchFromGitHub {
    owner = "thomaschrstnsn";
    repo = "screentime-web";
    rev = "b907a5a7e82bda7ff853e5bfc550b19d1edfbb2e";
    hash = "sha256-oekTHHC51J/g9BKe11g9+v8JfT/GMhka57lOb5po6VY=";
  };

  cargoHash = "sha256-842TsuUIG/RlIz7Yi76xSEjl/4fG73Z3qfOoQ/k8Yek";

  meta = with pkgs.lib; {
    description = "screentime-web";
    license = licenses.mit;
    platforms = lib.platforms.linux;
  };
}

