{ pkgs }:

let version = "0.2.0";
in
pkgs.rustPlatform.buildRustPackage {
  pname = "screentime-web";
  inherit version;

  src = pkgs.fetchFromGitHub {
    owner = "thomaschrstnsn";
    repo = "screentime-web";
    rev = "af43ca7649af846a2e36a657b1f9cf5e93db9624";
    hash = "sha256-epdpuSHmghJUOu1raC94jJgJ+8m18Ll/S+li4uEDVPE=";
  };

  cargoHash = "sha256-2qs/95iv4C5I9oKpJ8/1wQVRWnkg3ffvc3ZrVtchOvI";

  meta = with pkgs.lib; {
    description = "screentime-web";
    license = licenses.mit;
  };
}

