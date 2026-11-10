{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  asar,
  at-spi2-atk,
  at-spi2-core,
  atk,
  autoPatchelfHook,
  cairo,
  copyDesktopItems,
  cups,
  dbus,
  expat,
  glib,
  gsettings-desktop-schemas,
  gtk3,
  libGL,
  libgbm,
  libnotify,
  libpulseaudio,
  libsecret,
  libx11,
  libxcb,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxkbcommon,
  libxrandr,
  makeDesktopItem,
  makeShellWrapper,
  nspr,
  nss,
  pango,
  pipewire,
  systemdLibs,
  wrapGAppsHook3,
}:

stdenv.mkDerivation rec {
  pname = "antigravity-app";
  version = "2.31.0";
  buildId = "6379060755038208";

  src = fetchurl {
    url = "https://storage.googleapis.com/antigravity-public/antigravity-hub/${version}-${buildId}/linux-x64/Antigravity.tar.gz";
    hash = "sha256-MMzeof/wv2Q7f256pJMkDRPsHYZqz0+JwqbMOiwzNpw=";
  };

  sourceRoot = "Antigravity-x64";

  __structuredAttrs = true;
  strictDeps = true;

  nativeBuildInputs = [
    asar
    autoPatchelfHook
    copyDesktopItems
    makeShellWrapper
    wrapGAppsHook3
  ];

  buildInputs = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    dbus
    expat
    glib
    gsettings-desktop-schemas
    gtk3
    libgbm
    libx11
    libxcb
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxkbcommon
    libxrandr
    nspr
    nss
    pango
    systemdLibs
  ];

  runtimeDependencies = map lib.getLib [
    libnotify
    libpulseaudio
    libsecret
    pipewire
  ];

  appendRunpaths = [ "${lib.getLib libGL}/lib" ];

  dontWrapGApps = true;

  desktopItems = [
    (makeDesktopItem {
      name = "antigravity-app";
      desktopName = "Antigravity App";
      genericName = "AI Development Platform";
      comment = "Desktop environment for managing autonomous agents across independent projects";
      exec = "antigravity %U";
      icon = "antigravity";
      categories = [
        "Development"
        "Utility"
      ];
      mimeTypes = [ "x-scheme-handler/antigravity" ];
      startupWMClass = "antigravity";
    })
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/antigravity
    cp -r . $out/share/antigravity

    asar extract-file resources/app.asar icon.png 2>/dev/null || true
    if [ -f icon.png ]; then
      install -Dm644 icon.png $out/share/icons/hicolor/512x512/apps/antigravity.png
    fi

    runHook postInstall
  '';

  postFixup = ''
    makeShellWrapper $out/share/antigravity/antigravity $out/bin/antigravity \
      "''${gappsWrapperArgs[@]}" \
      --set __HM_SHELL_EXECED 1 \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}"

    ln -sf $out/bin/antigravity $out/bin/antigravity-app
  '';

  meta = {
    description = "Desktop environment for managing multiple autonomous agents across independent projects";
    homepage = "https://antigravity.google";
    downloadPage = "https://antigravity.google/download";
    changelog = "https://antigravity.google/changelog";
    license = lib.licenses.unfree;
    mainProgram = "antigravity";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
