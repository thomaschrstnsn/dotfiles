{ pkgs, ... }:
with pkgs;
rec {
  sketchybar-app-font = callPackage ./sketchybar-app-font.nix { };
  SbarLua = callPackage ./SbarLua.nix { };
  menus = callPackage ./menus.nix { };
  event_providers = callPackage ./event_providers.nix { };

  config = callPackage ./config.nix { inherit SbarLua menus event_providers; };
}
