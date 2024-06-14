{ stdenv }:

stdenv.mkDerivation {
  name = "event_providers";
  src = ../../darwin/modules/sketchybar/helpers/event_providers;

  installPhase = ''
    mkdir -p $out/bin
    cp ./cpu_load/bin/cpu_load $out/bin/
    cp ./network_load/bin/network_load $out/bin/
  '';
}
