{ lib, stdenvNoCC, fetchgit }:
stdenvNoCC.mkDerivation rec {
  name = "mpv-Subsearch";
  version = "1.0.0";

  src = fetchgit {
    url = "https://github.com/CogentRedTester/mpv-sub-select.git";
    rev = "0kyzh1y1b57q6acvdkb6zyj9hapv56mk9m541h11n5nnwljql705";
    sha256 = "sha256-BRyKJeXWFhsCDKTUNKsp+yqYpP9mzbaZMviUFXyA308=";
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
    maintainers = [ lib.maintainers.juca ];
  };
}
