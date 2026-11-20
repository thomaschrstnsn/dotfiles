{ lib, stdenvNoCC, fetchurl, p7zip, variant ? "TermSC" }:

# Slim Sarasa Gothic (https://github.com/be5invis/Sarasa-Gothic): nixpkgs' sarasa-gothic
# bundles every family x orthography as TTCs (~820 MiB). Upstream also publishes one
# archive per family+orthography, so fetch just the one we use.
#
# To add a variant (e.g. "MonoSC", "TermSlabJ", "FixedTC"), add its hash below:
#   nix store prefetch-file https://github.com/be5invis/Sarasa-Gothic/releases/download/v<version>/Sarasa<variant>-TTF-Unhinted-<version>.7z
let
  version = "1.0.43";
  hashes = {
    TermSC = "sha256-9WzrZV0/sXGj83DchR5SA64w/67NEvA1s+zGRW0nJSc=";
  };
in
stdenvNoCC.mkDerivation {
  pname = "sarasa-${lib.toLower variant}";
  inherit version;

  src = fetchurl {
    url = "https://github.com/be5invis/Sarasa-Gothic/releases/download/v${version}/Sarasa${variant}-TTF-Unhinted-${version}.7z";
    hash = hashes.${variant} or (throw "sarasa: no hash for variant '${variant}', add it to pkgs/sarasa.nix");
  };

  nativeBuildInputs = [ p7zip ];

  unpackPhase = ''
    runHook preUnpack
    7z x -y "$src"
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
    install -Dm644 -t $out/share/fonts/truetype *.ttf
    runHook postInstall
  '';

  meta = {
    description = "Sarasa Gothic ${variant} (unhinted TTF)";
    homepage = "https://github.com/be5invis/Sarasa-Gothic";
    license = lib.licenses.ofl;
    platforms = lib.platforms.all;
  };
}
