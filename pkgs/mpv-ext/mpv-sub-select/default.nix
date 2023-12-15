{ lib
, stdenvNoCC
, source
,
}:
stdenvNoCC.mkDerivation (
  source
  // {
    dontBuild = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/mpv/scripts
      cp sub-select.lua $out/share/mpv/scripts/sub-select.lua

      runHook postInstall
    '';

    passthru.scriptName = "sub-select.lua";
  }
    // {
    version = "unstable-${source.date}";

    meta = {
      description = "Automatically skip chapters based on title";
      homepage = "https://github.com/CogentRedTester/mpv-sub-select";
      maintainers = [ lib.maintainers.iynaix ];
    };
  }
)
