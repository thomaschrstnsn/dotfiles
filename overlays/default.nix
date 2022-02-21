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

          versionRevSha = {
            "aarch64-darwin" =
              {
                version = "unstable-2022-01-22";
                rev = "fe86f24a21772810cd186d1b5bd2eff84b2701a9";
                sha256 = "0m40i07gls47l5ibr6ys0qnqnfhqk9fnq0k7wdjmy04l859zqpw3";
              };
            "x86_64-darwin" = {
              version = "unstable-2022-01-30";
              rev = "916d9133f9d13fb38678baa3d0adf3cfb9dff003";
              sha256 = "191d3nm05fss03lcrqrfzgsy0g01qa34d3s4kvby3xqghda2wla4";
            };
          }.${super.pkgs.stdenv.hostPlatform.system};
        in
        super.yabai.overrideAttrs (
          o: rec {
            version = versionRevSha.version;
            src = super.fetchFromGitHub {
              owner = "koekeishiya";
              repo = "yabai";
              rev = versionRevSha.rev;
              sha256 = versionRevSha.sha256;
            };
            prePatch = ''
              substituteInPlace makefile ${replace};
            '';
            buildPhase = ''
              PATH=/usr/bin:/bin /usr/bin/make install #yo
            '';
          }
        );
    })
  ];
}
