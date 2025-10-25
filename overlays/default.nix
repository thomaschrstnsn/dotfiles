{ pkgs, system, lib, myPkgs }:

{
  overlays = [
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

    # bug in snacks.nvim that is is nixpkgs...
    # version = "2025-10-20";
    # src = fetchFromGitHub {
    #   owner = "folke";
    #   repo = "snacks.nvim";
    #   rev = "a54477b0acfb7c7cf7e55edc2619ffcd23b2f357";
    #   sha256 = "1zpgybhdf74rbwqpycyb88qydcs36yy551ij8si3f0108ag04s88";
    # };
    (final: prev: {
      vimPlugins = prev.vimPlugins // {
        snacks-nvim = prev.vimPlugins.snacks-nvim.overrideAttrs (oldAttrs: {
          version = "main-2025-10-25";
          src = prev.fetchFromGitHub {
            owner = "folke";
            repo = "snacks.nvim";
            rev = "e1dc6b3bddd0d16d0faa5d6802a975f7a7165b2a";
            sha256 = "sha256-ZFaZ+q9JXQj+s5WcFZjHVCmgWTeVWXezL65sk4n3TpU=";
          };
          doCheck = false; # Disable the require check
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
