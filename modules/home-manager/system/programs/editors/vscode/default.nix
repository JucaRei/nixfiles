{
  config,
  lib,
  pkgs,
  inputs,
  useNixGL ? false,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.system.programs.editors.vscode;

  nixGL = import ../../../../../../lib/nixGL.nix { inherit pkgs; };
  nixGLWrapper = if useNixGL then nixGL.wrapper else (x: x);
  # nixGLWrapper = if useNixGL then nixGL.wrapDesktopFiles else (x: x);

  # Settings
  jsonPath = "${./settings.json}";
  userSettingsRaw = builtins.fromJSON (builtins.readFile jsonPath);
  remoteExtensions = {
    "remote.SSH.defaultExtensions" = map (x: x.vscodeExtUniqueID) (userSettingsRaw.extensions or [ ]); # Assume JSON has "extensions" array
  };
  userSettings = userSettingsRaw // remoteExtensions;
in
{
  options = {
    system.programs.editors.vscode = {
      enable = mkEnableOption "VS Code with declarative settings, extensions, and nixGL auto-wrap";
      enableConfigurableSettings = mkEnableOption "Whether to enable user settings management";
    };
  };

  config = mkIf cfg.enable {
    nixpkgs.overlays = [
      inputs.nix4vscode.overlays.default
    ];

    # Limpa automaticamente settings.json do VS Code caso tenha sido transformado em arquivo físico
    # antes do checkLinkTargets do Home Manager, evitando erro de "file is in the way of replacement"
    home.activation.cleanVscodeSettings = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
      for f in "$HOME/.config/Code/User/settings.json" \
               "$HOME/.config/Code/User/profiles"/*/settings.json \
               "$HOME/Library/Application Support/Code/User/settings.json" \
               "$HOME/Library/Application Support/Code/User/profiles"/*/settings.json; do
        if [ -e "$f" ] && [ ! -L "$f" ]; then
          $DRY_RUN_CMD rm -f "$f" 2>/dev/null || true
        fi
      done
    '';

    home = {
      packages = with pkgs; [
        prettier
        nil
        nixfmt
        sf-mono-liga-bin
      ];
    };

    programs.vscode = {
      enable = true;

      # - NixOS (useNixGL = false) → pure vscode
      # - Debian/Ubuntu/etc. (useNixGL = true) → nixGL-wrapped vscode
      package = if useNixGL then nixGLWrapper pkgs.vscode-fhs else pkgs.vscode;
      mutableExtensionsDir = true; # Permite instalar extensões manualmente pela interface do VS Code

      profiles.default = mkIf cfg.enableConfigurableSettings {
        userSettings = userSettings // {
          "workbench.panel.defaultLocation" = "right";
          "chat.editor.fontSize" = 12;
        };
        extensions =
          with pkgs.vscode-extensions;
          [
            # Nix
            jnoortheen.nix-ide
            jeff-hykin.better-nix-syntax

            # Editor
            oderwat.indent-rainbow
            ms-vscode-remote.remote-ssh
          ]
          ++ pkgs.nix4vscode.forVscode [
            "davidbwaters.macos-modern-theme"
            "comdec.simple-icons"
            "tombonnike.vscode-status-bar-format-toggle"
            "natqe.reload"
            "redcrafter07.red-theme"
          ];
      };
    };
  };
}
