{ config, lib, pkgs, inputs, useNixGL ? false, ... }:
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

  # User dir for settings (cross-platform)
  settingsDir =
    if pkgs.stdenv.isDarwin then "${config.home.homeDirectory}/Library/Application Support/Code/User"
    else "${config.xdg.configHome}/Code/User";
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

    home = {
      packages = with pkgs; [
        prettier
        nil
        nixpkgs-fmt
        sf-mono-liga-bin
      ];


      # file = mkIf isWayland {
      #   ".config/code-flags.conf".text = ''
      #     --enable-features=UseOzonePlatform
      #     --ozone-platform=wayland
      #     --enable-features=WaylandWindowDecorations
      #   '';
      # };

      activation = mkIf cfg.enableConfigurableSettings {
        # Force declarative settings by removing & regenerating user file on activation
        vscodeSettings = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
          rm -f "${settingsDir}/settings.json"
        '';

        afterClean = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          mkdir -p "${settingsDir}"
          ${pkgs.coreutils}/bin/cat ${(pkgs.formats.json {}).generate "settings.json" userSettings} > "${settingsDir}/settings.json"
        '';
      };
    };

    programs.vscode = {
      enable = true;

      # - NixOS (useNixGL = false) → pure vscode
      # - Debian/Ubuntu/etc. (useNixGL = true) → nixGL-wrapped vscode
      package = nixGLWrapper pkgs.vscode-fhs;

      profiles.default = mkIf cfg.enableConfigurableSettings {
        inherit userSettings;
        extensions = with pkgs.vscode-extensions; [
          # Nix
          jnoortheen.nix-ide
          jeff-hykin.better-nix-syntax

          # Editor
          oderwat.indent-rainbow
          ms-vscode-remote.remote-ssh
        ] ++
        pkgs.nix4vscode.forVscode [
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
