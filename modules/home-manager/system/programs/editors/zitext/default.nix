{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.system.programs.editors.zitext;
  inherit (lib)
    mkEnableOption
    mkIf
    mkDefault
    mkOption
    types
    ;
in
{
  options.system.programs.editors.zitext = {
    enable = mkEnableOption "ZITEXT text editor";

    default = mkOption {
      type = types.bool;
      default = true;
      description = "Define o ZITEXT como editor padrão de texto plano (text/plain).";
    };

    package = mkOption {
      type = types.package;
      default = pkgs.zitext;
      description = "Pacote do ZITEXT a ser utilizado.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      cfg.package
    ];

    # Previne corrupção visual e crashes de compositing do WebKitGTK / Tauri em VMs
    home.sessionVariables = {
      WEBKIT_DISABLE_COMPOSITING_MODE = mkDefault "1";
      WEBKIT_DISABLE_DMABUF_RENDERER = mkDefault "1";
    };

    # Provisiona arquivo .desktop físico e sem symlinks em ~/.local/share/applications
    # Necessário para o DWM / Quickshell (dwm-default-apps exige arquivo real com ! -L e MimeType declarado)
    home.activation.zitextDesktopEntry = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD mkdir -p "$HOME/.local/share/applications"
      $DRY_RUN_CMD rm -f "$HOME/.local/share/applications/zitext.desktop"
      $DRY_RUN_CMD cat <<'EOF' > "$HOME/.local/share/applications/zitext.desktop"
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
EOF
      $DRY_RUN_CMD chmod 644 "$HOME/.local/share/applications/zitext.desktop" 2>/dev/null || true
    '';

    xdg.mimeApps = mkIf cfg.default {
      defaultApplications = {
        "text/plain" = mkDefault "zitext.desktop";
      };
      associations.added = {
        "text/plain" = "zitext.desktop";
      };
    };
  };
}
