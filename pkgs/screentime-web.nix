{ pkgs }:

let version = "0.2.1";
in
pkgs.rustPlatform.buildRustPackage {
  pname = "screentime-web";
  inherit version;

  src = pkgs.fetchFromGitHub {
    owner = "thomaschrstnsn";
    repo = "screentime-web";
    rev = "590fcc0aca73494de759a05d9822d71cc95cdddf";
    hash = "sha256-VeorvlYId5XCU+gUKAIezmyX/6kiUpj0QdtkfLYP9JA";
  };

  cargoHash = "sha256-+fdT/Aeio+cW/xHrJJ1DS0gEGX5/bUe9k+HFarn1qTs";

  meta = with pkgs.lib; {
    description = "screentime-web";
    license = licenses.mit;
  };
}

