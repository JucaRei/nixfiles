{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf mkEnableOption mkOption;
  inherit (lib.types) package;
  cfg = config.system.programs.editors.antigravity;

  # Wrapper script / desktop launcher se o binário nativo estiver em ~/.gemini/antigravity-ide ou no PATH
  antigravityLauncher = pkgs.writeShellScriptBin "antigravity" ''
    if [ -x "$HOME/.gemini/antigravity-ide/bin/agentapi" ]; then
      exec "$HOME/.gemini/antigravity-ide/bin/agentapi" "$@"
    elif command -v agy >/dev/null 2>&1; then
      exec agy "$@"
    else
      echo "Antigravity IDE binary not found in PATH or ~/.gemini/antigravity-ide"
      exit 1
    fi
  '';
in
{
  options = {
    system.programs.editors.antigravity = {
      enable = mkEnableOption "Google Antigravity AI IDE";
      package = mkOption {
        type = package;
        default = antigravityLauncher;
        description = "Package or wrapper for Antigravity IDE.";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      cfg.package
    ];

    # Desktop Entry para o lançador de aplicativos
    xdg.desktopEntries.antigravity = {
      name = "Antigravity IDE";
      genericName = "AI Code Editor";
      comment = "Google DeepMind Advanced Agentic Coding IDE";
      exec = "antigravity %F";
      icon = "code";
      terminal = false;
      categories = [ "Development" "IDE" "TextEditor" ];
      mimeType = [ "text/plain" "inode/directory" ];
    };
  };
}
