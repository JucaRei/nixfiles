{
  pname,
  rev,
  filename,
  url,
  sha256,
  meta,
}: {
  pkgs,
  stdenvNoCC,
  ...
}:
stdenvNoCC.mkDerivation {
  inherit pname;
  version = builtins.substring 0 8 rev;

  src = pkgs.fetchurl {
    inherit url sha256;
  };

  dontBuild = true;
  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -Dm644 $src $out/share/mpv/scripts/${filename}

    runHook postInstall
  '';

  passthru.scriptName = filename;

  inherit meta;
}
