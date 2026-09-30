{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.system.programs.editors.gedit;
  inherit (lib)
    mkEnableOption
    mkIf
    mkDefault
    mkOption
    types
    ;
in
{
  options.system.programs.editors.gedit = {
    enable = mkEnableOption "GNOME Text Editor (gedit)";

    default = mkOption {
      type = types.bool;
      default = true;
      description = "Define o gedit como editor padrão de texto plano (text/plain).";
    };

    package = mkOption {
      type = types.package;
      default = pkgs.gedit;
      description = "Pacote do gedit a ser utilizado.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      cfg.package
    ];

    home.sessionVariables = mkIf cfg.default {
      EDITOR = mkDefault "gedit";
    };

    # Assegura que o arquivo .desktop físico exista em ~/.local/share/applications
    # Necessário para que o DWM Quickshell (dwm-default-apps) consiga ler sem symlinks
    home.activation.geditDesktopEntry = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD mkdir -p "$HOME/.local/share/applications"
      if [ -f "${cfg.package}/share/applications/org.gnome.gedit.desktop" ]; then
        $DRY_RUN_CMD rm -f "$HOME/.local/share/applications/org.gnome.gedit.desktop" "$HOME/.local/share/applications/gedit.desktop"
        $DRY_RUN_CMD cp -f "${cfg.package}/share/applications/org.gnome.gedit.desktop" "$HOME/.local/share/applications/org.gnome.gedit.desktop"
        $DRY_RUN_CMD chmod 644 "$HOME/.local/share/applications/org.gnome.gedit.desktop" 2>/dev/null || true
        $DRY_RUN_CMD ln -sf org.gnome.gedit.desktop "$HOME/.local/share/applications/gedit.desktop"
      fi
    '';

    xdg.mimeApps = mkIf cfg.default {
      defaultApplications = {
        "text/plain" = mkDefault "org.gnome.gedit.desktop";
      };
      associations.added = {
        "text/plain" = "org.gnome.gedit.desktop";
      };
    };
  };
}
