{ pkgs, system, lib, myPkgs, hyprpanel }:

{
  overlays = [
    hyprpanel.overlay
    (self: super: {
      inherit myPkgs;
    })

    (final: prev: {
      vimPlugins = prev.vimPlugins // {
        kulala-nvim = prev.vimPlugins.kulala-nvim.overrideAttrs (oldAttrs: {
          patches = (oldAttrs.patches or [ ]) ++ [
            ./kulala-treesitter.patch # path to your patch file
          ];
        });
      };
    })

    (final: prev: {
      tmuxPlugins = prev.tmuxPlugins // {
        fuzzback = prev.tmuxPlugins.fuzzback.overrideAttrs
          (_: {
            version = "unstable-2025-05-07";

            src = prev.fetchFromGitHub {
              owner = "roosta";
              repo = "tmux-fuzzback";
              rev = "0aafeeec4555d7b44a5a2a8252f29c238d954d59";
              hash = "sha256-2UlyX5X3rlvrMJ9r8imlQzZyeaubzL0Lp3fX++VUUhQ";
            };
          });
      };
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
