{
  lib,
  stdenvNoCC,
  fetchgit,
}:
stdenvNoCC.mkDerivation rec {
  name = "mpv-nextfile";
  version = "1.0.0";

  src = fetchgit {
    url = "https://github.com/jonniek/mpv-nextfile.git";
    rev = "b8f7a4d6224876bf26724a9313a36e84d9ecfd81";
    sha256 = "00yr212zfahz0g3rg3w7l9xv4pjd2n0p21vcfhp1p6pf8s4prpq1";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/mpv/scripts
    cp nextfile.lua $out/share/mpv/scripts/nextfile.lua

    runHook postInstall
  '';

  passthru.scriptName = "nextfile.lua";

  meta = {
    description = "Force open next or previous file in the currently playing files directory";
    homepage = "https://github.com/jonniek/mpv-nextfile";
    license = lib.licenses.unlicense;
    maintainers = [lib.maintainers.juca];
  };
}
