{ lib, stdenvNoCC, fetchFromGitHub, }:

stdenvNoCC.mkDerivation {
  pname = "sddm-theme-abstractdark";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "3ximus";
    repo = "abstractdark-sddm-theme";
    rev = "e817d4b27981080cd3b398fe928619ffa16c52e7";
    hash = "sha256-XmhTVs/1Hzrs+FBRbFEOSIFOrRp0VTPwIJmSa2EgIeo=";
  };

  installPhase = ''
    mkdir -p $out/share/sddm/themes/abstractdark
    cp $src/* $out/share/sddm/themes/abstractdark
  '';

  meta = with lib; {
    homepage = "https://github.com/3ximus/abstractdark-sddm-theme";
    license = licenses.gpl3;
    description = "Abstract Dark theme for SDDM";
    platforms = platforms.all;
  };
}
