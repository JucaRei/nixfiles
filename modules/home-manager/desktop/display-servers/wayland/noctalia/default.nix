{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkOption;
  inherit (lib.types) bool;
  cfg = config.desktop.wayland;
  isNoctalia = config.desktop.display-servers.backend == "wayland" && cfg.shell == "noctalia";

  # Script para alternar/abrir o launcher do Noctalia Shell
  noctaliaLauncher = pkgs.writeShellScriptBin "noctalia-launcher" ''
    if command -v noctalia >/dev/null 2>&1; then
      noctalia toggle-launcher 2>/dev/null || noctalia launcher 2>/dev/null || noctalia &
    elif command -v noctalia-shell >/dev/null 2>&1; then
      noctalia-shell toggle-launcher 2>/dev/null || noctalia-shell launcher 2>/dev/null || noctalia-shell &
    fi
  '';
in
{
  options.desktop.wayland.noctalia = {
    enable = mkOption {
      type = bool;
      default = isNoctalia;
      description = "Habilitar Noctalia Shell integrado para ambientes Wayland";
    };
  };

  config = mkIf isNoctalia {
    home.packages = [
      pkgs.noctalia-shell
      noctaliaLauncher
    ];
  };
}
