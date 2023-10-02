{
  lib,
  stdenvNoCC,
  fetchurl,
  pkgs,
}:
# let
#   variants = [ "8-0-4-1" "8-0-4-1_Lineart" "16-0-4-1" ];
#   installString = variant: (file: "install -Dm644 ${file} $out/${file}") "FSRCNNX_x2_${variant}.glsl";
# in
stdenvNoCC.mkDerivation rec {
  pname = "fsrcnnx";
  version = "1.1";

  src = fetchurl {
    name = "important";
    url = "https://github.com/igv/FSRCNN-TensorFlow/releases/download/1.1/checkpoints_params.7z";
    sha256 = "sha256-h5B7DU0W5B39rGaqC9pEqgTTza5dKvUHTFlEZM1mfqo=";
  };
  src8 = fetchurl {
    url = "https://github.com/igv/FSRCNN-TensorFlow/releases/download/${version}/FSRCNNX_x2_8-0-4-1.glsl";
    sha256 = "sha256-6ADbxcHJUYXMgiFsWXckUz/18ogBefJW7vYA8D6Nwq4=";
  };
  src16 = fetchurl {
    url = "https://github.com/igv/FSRCNN-TensorFlow/releases/download/${version}/FSRCNNX_x2_16-0-4-1.glsl";
    sha256 = "sha256-1aJKJx5dmj9/egU7FQxGCkTCWzz393CFfVfMOi4cmWU=";
  };

  nativeBuildInputs = [pkgs.p7zip];

  unpackPhase = ''
    7z -aoa x ${src}
  '';

  installPhase = ''
    runHook preInstall

    ls -lah

    install -Dm644 ${src8} $out/FSRCNNX_x2_8-0-4-1.glsl
    install -Dm644 FSRCNNX_x2_8-0-4-1_LineArt.glsl $out/FSRCNNX_x2_8-0-4-1_LineArt.glsl
    install -Dm644 ${src16} $out/FSRCNNX_x2_16-0-4-1.glsl

    runHook postInstall
  '';

  meta = with lib; {
    description = "An implementation of the Fast Super-Resolution Convolutional Neural Network in TensorFlow";
    homepage = "https://github.com/igv/FSRCNN-TensorFlow";
    license = licenses.lgpl3Plus;
    maintainers = with maintainers; [lunik1];
    platforms = platforms.all;
  };
}
