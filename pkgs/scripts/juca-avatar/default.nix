{ stdenvNoCC
, imagemagick
}:

stdenvNoCC.mkDerivation rec {
  name = "juca-avatar";
  phases = [ "installPhase" "fixupPhase" ];

  src = ./face.jpg;

  installPhase = ''
    mkdir -p "$out/share/faces" "$out/share/sddm/faces"
    cp "${src}" "$out/share/faces/juca.jpg"
    ${imagemagick}/bin/convert \
      -define colorspace:auto-grayscale=false \
      "${src}" "png:$out/share/sddm/faces/juca.face.icon"
  '';
}
