# https://github.com/NotAShelf/nyx/blob/b1f789e7b4da072cfbc912df90836c777c4555cf/pkgs/overlays/anime4k/default.nix
{
  lib,
  stdenvNoCC,
  fetchzip,
}:
stdenvNoCC.mkDerivation rec {
  pname = "anime4k";
  version = "4.0.1";

  src = fetchzip {
    url = "https://github.com/bloc97/Anime4K/releases/download/v${version}/Anime4K_v4.0.zip";
    stripRoot = false;
    sha256 = "18x5q7zvkf5l0b2phh70ky6m99fx1pi6mhza4041b5hml7w987pl";
  };

  installPhase = ''
    mkdir $out
    cp *.glsl $out
  '';

  meta = with lib; {
    description = "A High-Quality Real Time Upscaler for Anime Video";
    homepage = "https://github.com/bloc97/Anime4K";
    license = licenses.mit;
  };
}
