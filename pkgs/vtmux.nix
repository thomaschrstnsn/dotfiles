{ lib, stdenvNoCC, fetchurl }:

# https://github.com/martintrojer/vtmux — tmux 3.8 reimplemented in Rust on libghostty-vt.
#
# Uses the upstream release binaries: building from source needs Zig 0.17 and fetches
# ghostty at build time, which does not fit the nix sandbox. The darwin binary only links
# system libs, and on linux we take the static musl build, so no patching is needed.
#
# vtmux behaves by the name it is started under: as `tmux` it *is* tmux (`tmux -V` prints
# `tmux 3.8`, uses tmux's sockets). So bin/tmux is a symlink, not a wrapper — a wrapper
# script would exec it as `vtmux`.
let
  version = "3.8-rc2";
  targets = {
    aarch64-darwin = {
      triple = "aarch64-apple-darwin";
      hash = "sha256-KS8obGpbXtbVZ159roOX2P6xeq+TMoQfEaK/oMNsRQE=";
    };
    aarch64-linux = {
      triple = "aarch64-unknown-linux-musl";
      hash = "sha256-HJvxE8FN2pQEnphvBWyk7eV5E/0NyQx3mBmbn5pAnxk=";
    };
    x86_64-linux = {
      triple = "x86_64-unknown-linux-musl";
      hash = "sha256-BiOCTi5XY0vOERlbhCAD0Ao3laaiNMim9koaZx0id7Q=";
    };
  };
  system = stdenvNoCC.hostPlatform.system;
  target = targets.${system} or (throw "vtmux: unsupported system ${system}");
in
stdenvNoCC.mkDerivation {
  pname = "vtmux";
  inherit version;

  src = fetchurl {
    url = "https://github.com/martintrojer/vtmux/releases/download/v${version}/vtmux-v${version}-${target.triple}.tar.gz";
    inherit (target) hash;
  };

  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 vtmux $out/bin/vtmux
    ln -s vtmux $out/bin/tmux
    install -Dm644 -t $out/share/doc/vtmux README.md CHANGELOG.md LICENSE
    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    $out/bin/vtmux -V | grep -qx "vtmux ${version}"
    $out/bin/tmux -V | grep -qx "tmux 3.8"
  '';

  meta = {
    description = "Drop-in tmux replacement in Rust on libghostty-vt (installed as tmux)";
    homepage = "https://github.com/martintrojer/vtmux";
    changelog = "https://github.com/martintrojer/vtmux/blob/main/CHANGELOG.md";
    license = lib.licenses.isc;
    mainProgram = "tmux";
    platforms = builtins.attrNames targets;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
