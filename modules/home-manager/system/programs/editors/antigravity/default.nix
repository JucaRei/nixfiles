{
  config,
  lib,
  pkgs,
  osConfig ? null,
  ...
}:
let
  inherit (lib)
    mkIf
    mkEnableOption
    mkOption
    optionalString
    ;
  inherit (lib.types)
    package
    nullOr
    port
    str
    either
    ;
  cfg = config.system.programs.editors.antigravity;
  isNixOS = osConfig != null;
in
{
  options = {
    system.programs.editors.antigravity = {
      enable = mkEnableOption "Google Antigravity AI IDE";
      package = mkOption {
        type = package;
        default = if isNixOS then pkgs.unstable.antigravity-ide-fhs else pkgs.unstable.antigravity-ide;
        description = "Package or wrapper for Antigravity IDE.";
      };
      remoteDebuggingPort = mkOption {
        type = nullOr (either port str);
        default = "9004";
        description = "Port to open Chrome DevTools Protocol (CDP) for automation (e.g. Antigravity Auto Accept).";
      };
    };
  };

  config = mkIf cfg.enable {
    home = {
      packages = [
        cfg.package
        (pkgs.writeShellScriptBin "antigravity" ''
          exec antigravity-ide ${
            optionalString (
              cfg.remoteDebuggingPort != null
            ) "--remote-debugging-port=${toString cfg.remoteDebuggingPort}"
          } "$@"
        '')
        pkgs.direnv
        pkgs.nix-direnv
        pkgs.nerd-fonts.victor-mono
      ];

      activation.configureAntigravityCdp = mkIf (cfg.remoteDebuggingPort != null) (
        lib.hm.dag.entryAfter [ "writeBoundary" ] ''
                    $DRY_RUN_CMD ${pkgs.python3}/bin/python3 -c '
          import json, os, re

          dir_path = os.path.expanduser("~/.antigravity-ide")
          os.makedirs(dir_path, exist_ok=True)
          path = os.path.join(dir_path, "argv.json")
          data = {}
          if os.path.exists(path):
              try:
                  with open(path, "r", encoding="utf-8") as f:
                      content = f.read()
                  clean = re.sub(r"//.*", "", content)
                  data = json.loads(clean) if clean.strip() else {}
              except Exception:
                  data = {}

          port = "${toString cfg.remoteDebuggingPort}"
          if data.get("remote-debugging-port") != port:
              data["remote-debugging-port"] = port
              with open(path, "w", encoding="utf-8") as f:
                  json.dump(data, f, indent=2)
                  f.write("\n")
          '
        ''
      );
    };

    xdg.desktopEntries = {
      # Sobrescreve (shadow) o antigravity-ide.desktop do nix-profile com flags de automação/CDP
      antigravity-ide = {
        name = "Antigravity IDE";
        comment = "Code Editing. Redefined.";
        genericName = "Text Editor";
        exec = "antigravity-ide ${
          optionalString (
            cfg.remoteDebuggingPort != null
          ) "--remote-debugging-port=${toString cfg.remoteDebuggingPort} "
        }%F";
        icon = "antigravity-ide";
        startupNotify = true;
        terminal = false;
        type = "Application";
        categories = [
          "Utility"
          "TextEditor"
          "Development"
          "IDE"
        ];
        mimeType = [
          "application/x-code-workspace"
          "text/plain"
          "inode/directory"
        ];
        settings = {
          StartupWMClass = "Antigravity IDE";
          Keywords = "vscode";
        };
        actions = {
          new-empty-window = {
            name = "New Empty Window";
            exec = "antigravity-ide ${
              optionalString (
                cfg.remoteDebuggingPort != null
              ) "--remote-debugging-port=${toString cfg.remoteDebuggingPort} "
            }--new-window %F";
            icon = "antigravity-ide";
          };
        };
      };

      # Esconde qualquer entrada legada 'antigravity.desktop' para prevenir duplicata no Rofi
      antigravity = {
        name = "Antigravity IDE (Legacy)";
        exec = "true";
        settings = {
          NoDisplay = "true";
        };
      };
    };

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
