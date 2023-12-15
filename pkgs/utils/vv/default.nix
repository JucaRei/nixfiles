{ lib
, stdenvNoCC
, makeWrapper
, file
, imagemagick
, fetchgit
,
}:
# based off derivation for lsix
# https://github.com/NixOS/nixpkgs/blob/master/pkgs/tools/graphics/lsix/default.nix
stdenvNoCC.mkDerivation rec{
  name = "vt-view";
  version = "2091123";

  src = fetchgit {
    url = "https://github.com/hackerb9/vv.git";
    rev = "20911233b940ebbf061894c2cef2e54b7763f7dd";
    sha256 = "05mm6al5rxln6y5xyywm37rbb0ncgdvb1ghb97m46vfnszyd12h6";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall
    install -Dm755 vv -t $out/bin
    runHook postInstall
  '';

  postFixup = ''
    wrapProgram $out/bin/vv \
      --prefix PATH : ${lib.makeBinPath [file imagemagick]}
  '';

  meta = {
    homepage = "https://github.com/hackerb9/vv";
    description = "A simple image viewer for video terminals capable of sixel graphics.";
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.iynaix ];
  };
}
