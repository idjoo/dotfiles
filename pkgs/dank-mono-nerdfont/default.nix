{ pkgs }:

pkgs.stdenv.mkDerivation {
  pname = "dank-mono-nerdfont";
  version = "1.0.0";

  src = ./src;

  installPhase = ''
    runHook preInstall

    install -Dm644 *.otf -t $out/share/fonts/opentype

    runHook postInstall
  '';
}
