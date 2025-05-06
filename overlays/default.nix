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
        version = "0.12.3";

        src = prev.fetchFromGitHub {
          owner = "tstack";
          repo = "lnav";
          rev = "v${version}";
          sha256 = "sha256-m0r7LAo9pYFpS+oimVCNCipojxPzMMsLLjhjkitEwow=";
        };

        nativeBuildInputs = with prev.pkgs; [
          autoconf
          automake
          zlib
          curl.dev
        ];
        buildInputs = with prev.pkgs; [
          bzip2
          ncurses
          pcre2
          readline
          sqlite
          curl
        ];
      });
    })
  ];
}
