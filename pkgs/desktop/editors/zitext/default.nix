{
  lib,
  appimageTools,
  fetchurl,
  makeWrapper,
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
    source "${makeWrapper}/nix-support/setup-hook"

    # Wrapper para contornar falhas de renderização/compositing do WebKitGTK/Tauri em VMs e GPUs legadas
    wrapProgram $out/bin/${pname} \
      --set-default WEBKIT_DISABLE_COMPOSITING_MODE 1 \
      --set-default WEBKIT_DISABLE_DMABUF_RENDERER 1

    # Cria/Instala arquivo .desktop canônico com validação estrita para o DWM / Quickshell
    mkdir -p "$out/share/applications"
    cat <<'EOF' > "$out/share/applications/zitext.desktop"
[Desktop Entry]
Type=Application
Name=ZITEXT
GenericName=Text Editor
Comment=Fast, minimalist text editor built with Rust and Tauri
Exec=zitext %F
Icon=zitext
Terminal=false
Categories=Utility;TextEditor;Development;
MimeType=text/plain;text/markdown;text/x-markdown;text/x-log;
StartupWMClass=zitext
Keywords=text;editor;plain;
EOF

    ln -sf zitext.desktop "$out/share/applications/ZITEXT.desktop"

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
