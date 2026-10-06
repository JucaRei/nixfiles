{
  lib,
  stdenv,
  makeWrapper,
  bash,
  bspwm,
  coreutils,
  jq,
}:

stdenv.mkDerivation {
  pname = "bsp-layout";
  version = "1.0.0";

  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp ${./bsp-layout.sh} $out/bin/bsp-layout
    chmod +x $out/bin/bsp-layout

    wrapProgram $out/bin/bsp-layout \
      --prefix PATH : ${lib.makeBinPath [
        bash
        bspwm
        coreutils
        jq
      ]}

    runHook postInstall
  '';

  meta = with lib; {
    description = "Dynamic layout manager for BSPWM";
    homepage = "https://github.com/phenax/bsp-layout";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
