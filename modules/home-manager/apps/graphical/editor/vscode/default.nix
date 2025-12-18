{ config, lib, pkgs, inputs, hostname, nixGLWrapper, ... }:
let
  inherit (lib) mkForce mkIf mkEnableOption;
  cfg = config.apps.graphical.editor.vscode;

  backend = config.desktop.backend or "x11";
  isWayland = backend == "wayland";

  # Settings
  jsonPath = "${./settings.json}";
  userSettingsRaw = builtins.fromJSON (builtins.readDir jsonPath);
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
    apps.graphical.editor.vscode = {
      enable = mkEnableOption "VS Code with declarative settings, extensions, and nixGL auto-wrap";
    };
  };

  config = mkIf cfg.enable {
    nixpkgs.overlays = [
      inputs.nix4vscode.overlays.default
    ];

    home = {
      packages = with pkgs; [
        nodePackages.prettier
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

      activation = {
        # Force declarative settings by removing & regenerating user file on activation
        vscodeSettings = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
          rm -f "${settingsDir}/settings.json"
        '';

        afterClean = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          ${pkgs.coreutils}/bin/cat ${(pkgs.formats.json {}).generate "settings.json" userSettings} > "${settingsDir}/settings.json"
        '';
      };
    };

    programs.vscode = {
      enable = true;
      inherit userSettings;

      # - NixOS (useNixGL = false) → pure vscode
      # - Debian/Ubuntu/etc. (useNixGL = true) → nixGL-wrapped vscode
      package = nixGLWrapper pkgs.vscode-fhs;
      mutableExtensionsDir = true;

      # commandLineArgs was removed in home-manager 25.05
      # commandLineArgs = mkIf isWayland [
      #   "--enable-features=UseOzonePlatform"
      #   "--ozone-platform=wayland"
      #   "--enable-features=WaylandWindowDecorations"
      # ];

      profiles = {
        "${hostname}" = {
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
  };
}
