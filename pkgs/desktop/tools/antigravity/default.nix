{
  buildFHSEnv,
  lib,
  pkgs,
}:
buildFHSEnv {
  name = "antigravity";
  targetPkgs =
    pkgs:
    (with pkgs; [
      alsa-lib
      at-spi2-atk
      at-spi2-core
      atk
      cairo
      cups
      curl
      dbus
      expat
      glib
      gtk3
      libdrm
      libglvnd
      libnotify
      libsecret
      libxkbcommon
      mesa
      nspr
      nss
      pango
      systemd
      udev
      vulkan-loader
      xorg.libX11
      xorg.libXScrnSaver
      xorg.libXcomposite
      xorg.libXcursor
      xorg.libXdamage
      xorg.libXext
      xorg.libXfixes
      xorg.libXi
      xorg.libXrandr
      xorg.libXrender
      xorg.libXtst
      xorg.libxcb
      xorg.libxkbfile
      xorg.libxshmfence
      zlib
    ]);

  runScript = pkgs.writeShellScript "antigravity-runner" ''
    if [ -x "$HOME/.gemini/antigravity-ide/bin/antigravity" ]; then
      exec "$HOME/.gemini/antigravity-ide/bin/antigravity" "$@"
    elif [ -x "$HOME/.gemini/antigravity-ide/antigravity" ]; then
      exec "$HOME/.gemini/antigravity-ide/antigravity" "$@"
    elif [ -x "$HOME/.gemini/antigravity-ide/bin/agentapi" ]; then
      exec "$HOME/.gemini/antigravity-ide/bin/agentapi" "$@"
    elif command -v agy >/dev/null 2>&1; then
      exec agy "$@"
    else
      echo "Google Antigravity IDE não encontrado em ~/.gemini/antigravity-ide ou PATH."
      exit 1
    fi
  '';

  extraInstallCommands = ''
    mkdir -p $out/share/applications
    ln -sf $out/bin/antigravity $out/bin/antigravity-ide-fhs

    cat > $out/share/applications/antigravity.desktop <<EOF
[Desktop Entry]
Name=Antigravity IDE
GenericName=AI Code Editor
Comment=Google DeepMind Advanced Agentic Coding IDE
Exec=antigravity %F
Icon=code
Terminal=false
Type=Application
Categories=Development;IDE;TextEditor;
MimeType=text/plain;inode/directory;
EOF
  '';

  meta = {
    description = "Google DeepMind Antigravity AI IDE (FHS environment for Linux/NixOS)";
    homepage = "https://deepmind.google/technologies/gemini/";
    license = lib.licenses.unfree;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = "antigravity";
  };
}
