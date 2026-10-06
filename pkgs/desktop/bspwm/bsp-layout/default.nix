{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
  bash,
  bc,
  bspwm,
  coreutils,
  gnused,
  gawk,
  procps,
}:

stdenv.mkDerivation rec {
  pname = "bsp-layout";
  version = "0.0.10";

  src = fetchurl {
    url = "https://github.com/phenax/bsp-layout/archive/${version}.tar.gz";
    sha256 = "ec71dd3438ff84ab3dd6d72673500a33158937112e9fcf87c64b02313bc1c1c8";
  };

  nativeBuildInputs = [ makeWrapper ];

  postPatch = ''
    sed -i "s#{{SOURCE_PATH}}#$out/lib/bsp-layout#" src/layout.sh
    sed -i "s#{{VERSION}}#${version}#" src/layout.sh bsp-layout.1

    # Desativa checagem estrita de 'man' que pode falhar em ambientes minimalistas
    substituteInPlace src/utils/common.sh \
      --replace 'for dep in bc bspc man;' 'for dep in bc bspc;'
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/bsp-layout/utils $out/lib/bsp-layout/layouts $out/bin $out/share/man/man1
    cp -r src/layout.sh $out/lib/bsp-layout/
    cp -r src/utils/*.sh $out/lib/bsp-layout/utils/
    cp -r src/layouts/*.sh $out/lib/bsp-layout/layouts/
    cp bsp-layout.1 $out/share/man/man1/

    chmod +x $out/lib/bsp-layout/layout.sh $out/lib/bsp-layout/utils/*.sh $out/lib/bsp-layout/layouts/*.sh

    makeWrapper $out/lib/bsp-layout/layout.sh $out/bin/bsp-layout \
      --prefix PATH : ${lib.makeBinPath [
        bash
        bc
        bspwm
        coreutils
        gnused
        gawk
        procps
      ]}

    runHook postInstall
  '';

  meta = with lib; {
    description = "Dynamic layout manager for bspwm (tall, wide, even, grid, tiled, monocle)";
    homepage = "https://github.com/phenax/bsp-layout";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
