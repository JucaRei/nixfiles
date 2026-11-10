{
  config,
  lib,
  pkgs,
  osConfig ? null,
  nixGLWrapper ? lib.id,
  ...
}:
let
  inherit (lib)
    mkIf
    mkEnableOption
    optionalAttrs
    optionals
    optionalString
    ;
  cfg = config.system.programs.editors.antigravity;
  isNixOS = osConfig != null;
  hasAntigravityApp =
    (builtins.elem "antigravity" (config.my.apps.gui or [ ]))
    || (builtins.elem "antigravity" (config.my.apps.cli or [ ]))
    || (cfg.app.enable or false);
in
{
  options = {
    system.programs.editors.antigravity = {
      enable = mkEnableOption "Google Antigravity AI IDE";
      package = lib.my.mkPkg (
        let
          base =
            if isNixOS then pkgs.unstable.antigravity-ide-fhs else nixGLWrapper pkgs.unstable.antigravity-ide;
        in
        pkgs.symlinkJoin {
          name = "antigravity-ide";
          paths = [ base ];
          nativeBuildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/antigravity-ide \
              --set NODE_TLS_REJECT_UNAUTHORIZED 0
          '';
        }
      ) "Package or wrapper for Antigravity IDE.";
      app = {
        enable = lib.my.mkBool false "Instalar também o aplicativo Antigravity além da IDE.";
        package = lib.my.mkPkg (
          if isNixOS then pkgs.antigravity else nixGLWrapper pkgs.antigravity
        ) "Pacote para o aplicativo Antigravity.";
      };
      remoteDebuggingPort =
        lib.my.mkOpt (lib.types.nullOr (lib.types.either lib.types.port lib.types.str)) "9004"
          "Port to open Chrome DevTools Protocol (CDP) for automation (e.g. Antigravity Auto Accept).";
    };
  };

  config = mkIf cfg.enable {
    home = {
      packages = [
        cfg.package
        pkgs.direnv
        pkgs.nix-direnv
        pkgs.nerd-fonts.victor-mono
      ]
      ++ optionals (!hasAntigravityApp) [
        (pkgs.writeShellScriptBin "antigravity" ''
          export NODE_TLS_REJECT_UNAUTHORIZED=0
          exec antigravity-ide ${
            optionalString (
              cfg.remoteDebuggingPort != null
            ) "--remote-debugging-port=${toString cfg.remoteDebuggingPort}"
          } "$@"
        '')
      ]
      ++ optionals (cfg.app.enable && !(builtins.elem "antigravity" (config.my.apps.gui or [ ]))) [
        cfg.app.package
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
    }
    // optionalAttrs (!hasAntigravityApp) {
      # Esconde qualquer entrada legada 'antigravity.desktop' apenas quando o aplicativo oficial antigravity não está instalado
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
