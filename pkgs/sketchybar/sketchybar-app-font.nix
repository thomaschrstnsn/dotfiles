{ stdenvNoCC, fetchurl }:

stdenvNoCC.mkDerivation rec {
  name = "sketchybar-app-font";
  version = "1.0.20";
  src = fetchurl {
    url = "https://github.com/kvndrsslr/sketchybar-app-font/releases/download/v${version}/sketchybar-app-font.ttf";
    hash = "sha256-pf3SSxzlNIdbXXHfRauFCnrVUMOd5J9sSUE9MsfWrwo=";
  };
  phases = [ "installPhase" ];
  installPhase = ''
    install -Dm644 $src $out/share/fonts/sketchybar-app-font/Regular.ttf
  '';
}
