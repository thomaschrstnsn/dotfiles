{ stdenv, SbarLua, menus, event_providers }:
stdenv.mkDerivation {
  name = "sketchybar-config";
  src = ../../darwin/modules/sketchybar;

  buildInputs = [ SbarLua menus event_providers ];

  buildPhase = 
    ''
    echo 'package.cpath = package.cpath .. ";"  .. "${SbarLua}/bin/sketchybar.so"' > helpers/init.lua
    mkdir -p helpers/event_providers/cpu_load/bin/
    mkdir -p helpers/event_providers/network_load/bin/
    mkdir -p helpers/menus/bin/
    cp ${menus}/bin/menus helpers/menus/bin
    cp ${event_providers}/bin/cpu_load helpers/event_providers/cpu_load/bin/
    cp ${event_providers}/bin/network_load helpers/event_providers/network_load/bin/
    '';

  installPhase = ''
    mkdir -p $out
    cp -r * $out
  '';
}
