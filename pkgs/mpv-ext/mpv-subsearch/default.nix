{
  lib,
  stdenvNoCC,
  fetchgit,
}:
stdenvNoCC.mkDerivation rec {
  name = "mpv-Subsearch";
  version = "1.0.0";

  src = fetchgit {
    url = "https://github.com/kelciour/mpv-scripts.git";
    rev = "9a5cda4fc8f0896cec27dca60a32251009c0e9c5";
    sha256 = "0kyzh1y1b57q6acvdkb6zyj9hapv56mk9m541h11n5nnwljql705";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/mpv/scripts
    cp sub-search.lua $out/share/mpv/scripts/sub-search.lua

    runHook postInstall
  '';

  passthru.scriptName = "sub-search.lua";

  meta = {
    description = "Search for a phrase in subtitles and skip to it";
    homepage = "https://github.com/kelciour/mpv-scripts";
    maintainers = [lib.maintainers.juca];
  };
}
