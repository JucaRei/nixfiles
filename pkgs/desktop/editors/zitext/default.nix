{
  lib,
  appimageTools,
  fetchurl,
}:
let
  pname = "zitext";
  version = "2.1.5";

  src = fetchurl {
    url = "https://github.com/zitrino-oss/zitext-editor/releases/download/v${version}/ZITEXT-${version}-Linux-x64.AppImage";
    hash = "sha256-0yXqTctW1zsqLsZsox3habrJQipGXP9RjBbqYbOS2lo=";
  };

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    # Instala arquivo .desktop garantindo nome canônico 'zitext.desktop'
    desktop_file=$(find ${appimageContents} -maxdepth 1 -name "*.desktop" | head -n 1)
    if [ -n "$desktop_file" ]; then
      install -m 444 -D "$desktop_file" "$out/share/applications/zitext.desktop"
      substituteInPlace "$out/share/applications/zitext.desktop" \
        --replace-warn 'Exec=AppRun' 'Exec=zitext' || true
      ln -sf zitext.desktop "$out/share/applications/ZITEXT.desktop"
    fi

    # Instala ícones se presentes
    if [ -d "${appimageContents}/usr/share/icons" ]; then
      mkdir -p "$out/share/icons"
      cp -r "${appimageContents}/usr/share/icons/"* "$out/share/icons/" 2>/dev/null || true
    elif [ -f "${appimageContents}/.DirIcon" ]; then
      install -m 444 -D "${appimageContents}/.DirIcon" "$out/share/icons/hicolor/512x512/apps/zitext.png"
    fi
  '';

  meta = with lib; {
    description = "Fast, minimalist text editor built with Rust and Tauri";
    homepage = "https://zitext.com/";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "zitext";
  };
}
