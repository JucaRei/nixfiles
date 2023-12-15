{ lib
, stdenvNoCC
, fetchFromGitHub
}:
stdenvNoCC.mkDerivation rec {

  # pname = "dynamic-crop.lua";
  # version = "1.0.0";

  src = fetchFromGitHub {
    repo = "Ashyni";
    owner = "mpv-scripts";
    url = "https://raw.githubusercontent.com/Ashyni/mpv-scripts/master/dynamic-crop.lua";
    sha256 = "sha256-Jhk5yiGHEygFF7oruVpwQXXLjlj1enpv9a9pK2ptZ6w=";
  };

  # src = dynamic-crop;

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/mpv/scripts
    cp dynamic-crop.lua $out/share/mpv/scripts/dynamic-crop.lua

    runHook postInstall
  '';

  passthru.scriptName = "dynamic-crop.lua";

  meta = {
    description = ''Script to "cropping" dynamically, hard-coded black bars detected with lavfi-cropdetect filter for Ultra Wide Screen or any screen (Smartphone/Tablet).'';
    homepage = "https://github.com/Ashyni/mpv-scripts";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.iynaix ];
  };
}
