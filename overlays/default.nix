{ pkgs, system, lib, myPkgs, hyprpanel }:

{
  overlays = [
    hyprpanel.overlay
    (self: super: {
      inherit myPkgs;
    })

    # left as an example of how to make an override
    # (final: prev: {
    #   ## 0.12.4 has an annoying issue with tmux TERM definition
    #   lnav = prev.lnav.overrideAttrs (_: rec {
    #     version = "0.13.0-rc4";
    #
    #     src = prev.fetchFromGitHub {
    #       owner = "tstack";
    #       repo = "lnav";
    #       rev = "v${version}";
    #       sha256 = "sha256-Dk+pFg+Tt1krFmEzoT4sW8dPd0x5kCD6vTIQVzAvs3A";
    #     };
    #   });
    # })
  ];
}
