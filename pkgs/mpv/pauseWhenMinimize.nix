{
  lib,
  pkgs,
  stdenvNoCC,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "mpv-pause-when-minimize";
  inherit (pkgs.mpv-unwrapped) version;

  src = "${pkgs.mpv-unwrapped.src.outPath}/TOOLS/lua/pause-when-minimize.lua";

  dontBuild = true;
  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -Dm644 $src $out/share/mpv/scripts/pause-when-minimize.lua

    runHook postInstall
  '';

  passthru.scriptName = "pause-when-minimize.lua";

  meta = with lib; {
    description = "Pauses the player video when minimizing, and unpauses it when brought up again.";
    homepage = "https://github.com/mpv-player/mpv/blob/master/TOOLS/lua/pause-when-minimize.lua";
    license = licenses.gpl2Plus;
    # mantainers = ;
  };
}
