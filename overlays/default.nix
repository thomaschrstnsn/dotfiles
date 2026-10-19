{ pkgs, system, lib, myPkgs, inputs ? { } }:

{
  overlays = [
    (final: prev: {
      inherit myPkgs;
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

    # atuin 18.23 fails on macOS; pin to last known good
    (final: prev: {
      atuin = prev.atuin.overrideAttrs (finalAttrs: _: {
        version = "18.18.0";

        src = prev.fetchFromGitHub {
          owner = "atuinsh";
          repo = "atuin";
          tag = "v${finalAttrs.version}";
          hash = "sha256-o20MwzWItvKcUIwrfxY60v2jqLnqLRbQ9lIevQWgVPI=";
        };

        cargoDeps = prev.rustPlatform.fetchCargoVendor {
          inherit (finalAttrs) pname version src;
          hash = "sha256-IoOIpcobVcmQBzDiSsT3WvVW6UiRpZ6NWE0GlzDLlYk=";
        };

        buildFeatures = [ "ai" "client" "clipboard" "daemon" "hex" "sync" ];
        cargoBuildFeatures = [ "ai" "client" "clipboard" "daemon" "hex" "sync" ];
        # 18.23's checkFlags/e2e test setup doesn't match 18.18
        doCheck = false;
      });
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
  ] ++ lib.optionals (inputs ? komorebi) [
    inputs.komorebi.overlays.default
  ];
}
