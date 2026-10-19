{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  wrapGAppsHook3,
  autoPatchelfHook,
  webkitgtk_4_1,
  gtk3,
  cairo,
  pango,
  atk,
  gdk-pixbuf,
  glib,
  dbus,
  openssl,
  librsvg,
  libsoup_3,
}:

stdenv.mkDerivation rec {
  pname = "mdhero";
  version = "0.2.10";

  src = fetchurl {
    url = "https://github.com/vaibhav-kakde-in/mdhero/releases/download/v${version}/MDHero_${version}_amd64.deb";
    sha256 = "f081fa3c1d242d6dab7e3785dfa8b2c0ef24ece7e42d7cf4fe7e75a320423084";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    wrapGAppsHook3
  ];

  buildInputs = [
    webkitgtk_4_1
    gtk3
    cairo
    pango
    atk
    gdk-pixbuf
    glib
    dbus
    openssl
    librsvg
    libsoup_3
    stdenv.cc.cc.lib
  ];

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x $src .
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share
    cp -r usr/share/* $out/share/ 2>/dev/null || true

    # Instala o binário nativo
    if [ -f usr/bin/mdhero ]; then
      install -m 755 -D usr/bin/mdhero $out/bin/mdhero
    elif [ -f usr/bin/MDHero ]; then
      install -m 755 -D usr/bin/MDHero $out/bin/mdhero
    fi

    # Atalho alternativo em maiúsculas
    ln -s $out/bin/mdhero $out/bin/MDHero 2>/dev/null || true

    # Garante Exec correto no .desktop
    if [ -f $out/share/applications/mdhero.desktop ]; then
      sed -i 's|^Exec=.*|Exec=mdhero %U|g' $out/share/applications/mdhero.desktop
    elif [ -f $out/share/applications/MDHero.desktop ]; then
      mv $out/share/applications/MDHero.desktop $out/share/applications/mdhero.desktop
      sed -i 's|^Exec=.*|Exec=mdhero %U|g' $out/share/applications/mdhero.desktop
    fi

    runHook postInstall
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --set WEBKIT_DISABLE_COMPOSITING_MODE 1
      --set WEBKIT_DISABLE_DMABUF_RENDERER 1
      --set NO_AT_BRIDGE 1
    )
  '';

  meta = {
    description = "Native, lightweight Markdown viewer and editor built with Tauri and Rust";
    homepage = "https://mdhero.app";
    changelog = "https://github.com/vaibhav-kakde-in/mdhero/releases/tag/v${version}";
    downloadPage = "https://github.com/vaibhav-kakde-in/mdhero/releases";
    license = lib.licenses.mit;
    mainProgram = "mdhero";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
