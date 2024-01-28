{ stdenvNoCC, makeFontsConf, lib, fetchgit, }:
stdenvNoCC.mkDerivation rec {
  name = "mpv-modernx";
  version = "0.6.0";

  src = fetchgit {
    url = "https://github.com/cyl0/ModernX.git";
    rev = "d053ea602d797bdd85d8b2275d7f606be067dc21";
    # sparseCheckout = ''
    #   dynamic-crop.lua
    # '';
    sha256 = "021rqv2p4zhpv5y3230lv5fcvmxhq084x3mp6yfvjmdxknbiz6hs";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/mpv/scripts
    cp modernx.lua $out/share/mpv/scripts/modernx.lua
    mkdir -p $out/share/fonts/truetype
    cp Material-Design-Iconic-Font.ttf $out/share/fonts/truetype

    runHook postInstall
  '';

  passthru.scriptName = "modernx.lua";
  # In order for mpv to find the custom font, we need to adjust the fontconfig search path.
  passthru.extraWrapperArgs = [
    "--set"
    "FONTCONFIG_FILE"
    (toString (makeFontsConf { fontDirectories = [ "/share/fonts" ]; }))
  ];

  meta = {
    description =
      "An MPV OSC script based on mpv-osc-modern that aims to mirror the functionality of MPV's stock OSC while with a more modern-looking interface.";
    homepage = "https://github.com/cyl0/ModernX";
    maintainers = [ lib.maintainers.iynaix ];
  };
}

# nix-shell -p nix-prefetch-git --run 'nix-prefetch-git https://github.com/cyl0/ModernX.git refs/heads/main'
