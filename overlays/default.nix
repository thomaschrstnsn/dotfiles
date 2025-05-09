{ pkgs, system, lib, myPkgs, hyprpanel }:

{
  overlays = [
    hyprpanel.overlay
    (self: super: {
      inherit myPkgs;
    })

    (final: prev: {
      ## 0.12.4 has an annoying issue with tmux TERM definition
      lnav = prev.lnav.overrideAttrs (_: rec {
        version = "0.13.0-beta4";

        src = prev.fetchFromGitHub {
          owner = "tstack";
          repo = "lnav";
          rev = "v${version}";
          sha256 = "sha256-Hsp745LMrTZERaOxM5W4pqoWuDNZLcYWBrRUSZUGVPQ=";
        };
      });
    })
  ];
}
