{ pkgs, lib }:

let version = "0.2.0";
in
pkgs.rustPlatform.buildRustPackage {
  pname = "screentime-collector";
  inherit version;

  src = pkgs.fetchFromGitHub {
    owner = "thomaschrstnsn";
    repo = "screentime-collector";
    rev = "09054917ab07b411cb92bb5d5611ea8da163b530";
    hash = "sha256-8iQDGCcIA/4vdnyGSka+m+G+D8xK39NBbf1XlWcWNv0";
  };

  cargoHash = "sha256-tUBcMkOu/2mW8CBYsEWmjrcIX2twvsym+OHrjJX2xZ0";

  meta = with pkgs.lib; {
    description = "screentime-collector: TimeKpr dbus to NATS";
    license = licenses.mit;
    platforms = lib.platforms.linux;
  };
}

