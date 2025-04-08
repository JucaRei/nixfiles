{ stdenvNoCC
, imagemagick
}:

stdenvNoCC.mkDerivation rec {
  name = "juca-avatar";
  phases = [ "installPhase" "fixupPhase" ];

  src = ./juca.jpg;

  installPhase = ''
    mkdir -p "$out/share/faces" "$out/share/sddm/faces"
    cp "${src}" "$out/share/faces/juca.jpg"
    ${imagemagick}/bin/convert \
      -define colorspace:auto-grayscale=false \
      "${src}" "png:$out/share/sddm/faces/juca.face.icon"
  '';
}

# nix-shell -p nix-prefetch-git --run 'nix-prefetch-git https://github.com/JucaRei/sddm-astronaut-theme.git refs/heads/master'
# nix-shell -p nix-prefetch-git --run 'nix-prefetch-git http://download.nvidia.com/XFree86/Linux-x86_64/340.108/NVIDIA-Linux-x86_64-340.108.run'
# nix-shell -p nix-prefetch-git --run 'nix-prefetch-git https://github.com/nix-community/nixGL refs/heads/backport/noGLVND'
