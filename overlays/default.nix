{ pkgs, system, lib, myPkgs }:

{
  overlays = [
    (self: super: {
      inherit myPkgs;

      myNerdfonts = self.nerdfonts.override { fonts = [ "JetBrainsMono" "Meslo" ]; };

      sketchybar = pkgs.myPkgs.sketchybar;

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
            version = "unstable-2022-01-22";
            src = super.fetchFromGitHub {
              owner = "koekeishiya";
              repo = "yabai";
              rev = "fe86f24a21772810cd186d1b5bd2eff84b2701a9";
              sha256 = "0m40i07gls47l5ibr6ys0qnqnfhqk9fnq0k7wdjmy04l859zqpw3";
            };
            prePatch = ''
              substituteInPlace makefile ${replace};
            '';
            buildPhase = ''
              PATH=/usr/bin:/bin /usr/bin/make install
            '';
          }
        );
    })
  ];
}
