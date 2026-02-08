{ pkgs, lib }:

let version = "0.0.1";
in
pkgs.rustPlatform.buildRustPackage {
  pname = "screentime-web";
  inherit version;

  src = pkgs.fetchFromGitHub {
    owner = "thomaschrstnsn";
    repo = "screentime-web";
    rev = "bae89510b083e413dc8d06471a15d30968eb73c9";
    hash = "sha256-1wF9yRP1RXePut9q5Xtpv/fTBqgU7na1ANqFpDDQXmE=";
  };

  cargoHash = "sha256-842TsuUIG/RlIz7Yi76xSEjl/4fG73Z3qfOoQ/k8Yek";

  meta = with pkgs.lib; {
    description = "screentime-web";
    license = licenses.mit;
    platforms = lib.platforms.linux;
  };
}

