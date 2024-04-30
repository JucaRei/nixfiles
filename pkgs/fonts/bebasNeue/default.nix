{ lib, stdenv, ... }:
stdenv.mkDerivation {
  pname = "BebasNeue-Regular";
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
    description = "Bebas Neue is a display family suitable for headlines, captions, and packaging, designed by Ryoichi Tsunekawa. It's based on the original Bebas typeface. The family is suitable for pro users due to its extended character set and OpenType features.";
    license = licenses.ofl;
    platforms = platforms.all;
  };
}
