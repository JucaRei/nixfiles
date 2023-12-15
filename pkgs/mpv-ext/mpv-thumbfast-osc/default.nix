{ lib, stdenvNoCC, fetchgit }:
stdenvNoCC.mkDerivation rec {
  name = "mpv-thumbfast";
  version = "1.0.0";

  src = fetchgit {
    url = "https://github.com/po5/thumbfast.git";
    rev = "03e93feee5a85bf7c65db953ada41b4826e9f905";
    # sparseCheckout = ''
    #   thumbfast.lua
    # '';
    sha256 = "0mzzf4ncnidzil6sqcri35zkwvl18hlvxzvsmr4jf4wfyl35dvp6";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/mpv/scripts
    cp thumbfast.lua $out/share/mpv/scripts/thumbfast.lua

    runHook postInstall
  '';

  passthru.scriptName = "thumbfast.lua";

  meta = {
    description = "High-performance on-the-fly thumbnailer for mpv";
    homepage = "https://github.com/po5/thumbfast";
    license = lib.licenses.mpl20;
    maintainers = [ lib.maintainers.juca ];
  };
}
