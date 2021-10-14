{ stdenv, forgit-git }:

stdenv.mkDerivation rec {
  pname = "forgit";
  version = "master";

  src = forgit-git;

  installPhase = ''
    install -D forgit.plugin.zsh --target-directory=$out/share/zsh-forgit
  '';
}