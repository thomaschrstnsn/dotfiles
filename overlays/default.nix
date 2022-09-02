{ pkgs, system, lib, myPkgs }:

{
  overlays = [
    (self: super: {
      inherit myPkgs;

      gum = myPkgs.gum;

      myNerdfonts = self.nerdfonts.override { fonts = [ "JetBrainsMono" "Meslo" ]; };

      sketchybar =
        super.sketchybar.overrideAttrs (
          o: rec {
            version = "2.8.6";
            src = super.fetchFromGitHub {
              owner = "FelixKratz";
              repo = "SketchyBar";
              rev = "v${version}";
              sha256 = "sha256-57Jd358pSyt++q4yrte2IVhB06KWvF/noEBy+toFncI=";
            };
          }
        );

      # https://github.com/azuwis/nix-config/blob/f927c463e42c7bf017ddf4a603c0fcd282bf1d98/darwin/overlays.nix#L72-L93
      yabai =
        let
          replace = {
            "aarch64-darwin" = "--replace '-arch x86_64' ''";
            "x86_64-darwin" = "--replace '-arch arm64e' '' --replace '-arch arm64' ''";
          }.${super.pkgs.stdenv.hostPlatform.system};
        in
        super.yabai.overrideAttrs (
          o: rec {
            version = "4.0.1";
            src = super.fetchFromGitHub {
              owner = "koekeishiya";
              repo = "yabai";
              rev = "v${version}";
              sha256 = "sha256-H1zMg+/VYaijuSDUpO6RAs/KLAAZNxhkfIC6CHk/xoI=";
            };
            prePatch = ''
              substituteInPlace makefile ${replace}
              substituteInPlace src/workspace.m --replace 'screen.safeAreaInsets.top' '0'
            '';
            buildPhase = ''
              PATH=/usr/bin:/bin /usr/bin/make install #yo
            '';
          }
        );
    })
  ];
}
