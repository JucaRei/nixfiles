{ lib, stdenv, ... }:
stdenv.mkDerivation {
  pname = "Abel-Regular";
  version = "0.0.1";
  src = ./.;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/fonts/truetype
    cp $src/*.ttf $out/share/fonts/truetype

    runHook postInstall
  '';

  meta = with lib; {
    description = "Abel font.";
    license = licenses.ofl;
    platforms = platforms.all;
  };
}
