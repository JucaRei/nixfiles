{ lib, stdenvNoCC, fetchgit }:

stdenvNoCC.mkDerivation rec {
  name = "mpv-dynamic-crop";

  src = fetchgit {
    url = "https://github.com/Ashyni/mpv-scripts.git";
    rev = "7bb1fa3a2a8193e15c88ed0b103224fa5fb41719";
    # sparseCheckout = ''
    #   dynamic-crop.lua
    # '';
    sha256 = "sha256-5zxFbydchQwQj+CoOoEaS+cQhA8csF9EsBIDcPNDcPc=";
  };

  installPhase = ''
    mkdir -p $out/share/mpv/scripts
    cp $src/dynamic-crop.lua $out/share/mpv/scripts/dynamic-crop.lua
  '';

  passthru.scriptName = "dynamic-crop.lua";

  meta = with lib; {
    description = ''Script to "cropping" dynamically, hard-coded black bars detected with lavfi-cropdetect filter for Ultra Wide Screen or any screen (Smartphone/Tablet).'';
    homepage = "https://github.com/Ashyni/mpv-scripts";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.juca ];
  };
}
