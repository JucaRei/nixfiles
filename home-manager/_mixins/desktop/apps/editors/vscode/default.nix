{ inputs, lib, pkgs, config, ... }:
let
  # installFor = [ "juca" ];
  # inherit (pkgs.stdenv) isLinux;
  inherit (lib) mkIf mkEnableOption;
  nixgl = import ../../../../../../lib/nixGL.nix { inherit config pkgs; };
  isGeneric = if (config.targets.genericLinux.enable) then true else false;
  cfg = config.desktop.apps.editors.vscode;

  settings-directory = if pkgs.stdenv.hostPlatform.isDarwin then "$HOME/Library/Application Support/Code/User" else "$HOME/.config/Code/User";
  extensions = import ./extensions.nix { inherit pkgs; };
  defaultExtensions = { "remote.SSH.defaultExtensions" = map (x: x.vscodeExtUniqueId) extensions; };
  # userSettings = (builtins.fromJSON (builtins.readFile ./settings.json)) // defaultExtensions;
  userSettings = (builtins.fromJSON (builtins.readFile ./settings.json)) // defaultExtensions;
  keybindings = builtins.fromJSON (builtins.readFile ./keybindings.json);
in
# lib.mkIf (lib.elem username installFor)
{
  options.desktop.apps.editors.vscode = {
    enable = mkEnableOption "Whether enable vscode.";
  };

  config = mkIf cfg.enable {
    nixpkgs.overlays = [
      inputs.catppuccin-vsc.overlays.default
      inputs.nix-vscode-extensions.overlays.default
    ];

    home = {
      packages = with pkgs; [
        # cross platform dev tools
        black
        nodePackages.prettier
        # rustfmt
        shellcheck
        shfmt
        # nil
        nixd
        nixpkgs-fmt
        # udev-gothic-nf
        # jetbrains-mono
        sf-mono-liga-bin

        # (nerdfonts.override {
        #   fonts = [
        #     "JetBrainsMono"
        #   ];
        # })
      ];

      file = mkIf (config.features.isWayland == true) {
        ".config/code-flags.conf".text = ''
          --enable-features=UseOzonePlatform
          --ozone-platform=wayland
          --enable-features=WaylandWindowDecorations
        '';
      };

      activation = {
        beforeCheckLinkTargets = {
          after = [ ];
          before = [ "checkLinkTargets" ];
          data = ''
            if [ -f "${settings-directory}/settings.json" ]; then
              rm "${settings-directory}/settings.json"
            fi
            if [ -f "${settings-directory}/keybindings.json" ]; then
              rm "${settings-directory}/keybindings.json"
            fi
          '';
        };

        afterWriteBoundary = {
          after = [ "writeBoundary" ];
          before = [ ];
          data = ''
            cat ${(pkgs.formats.json {}).generate "settings.json" userSettings} > "${settings-directory}/settings.json"
            cat ${(pkgs.formats.json {}).generate "keybindings.json" keybindings} > "${settings-directory}/keybindings.json"
          '';
        };
      };

      sessionVariables = {
        DIRENV_LOG_FORMAT = "";
      };
    };
    programs = {
      vscode = {
        inherit extensions userSettings keybindings;
        enable = true;
        mutableExtensionsDir = true;
        package = if isGeneric then (nixgl pkgs.unstable.vscode-fhs) else pkgs.unstable.vscode-fhs;
        enableUpdateCheck = false;
        enableExtensionUpdateCheck = false;
      };
      direnv = {
        enable = true;
        package = pkgs.unstable.direnv;
        nix-direnv = {
          enable = true;
          package = pkgs.unstable.nix-direnv;
        };
        silent = false;
        enableBashIntegration = true;
        stdlib = ''
          : ''${XDG_CACHE_HOME:=$HOME/.cache}
          declare -A direnv_layout_dirs
          direnv_layout_dir() {
              echo "''${direnv_layout_dirs[$PWD]:=$(
                  echo -n "$XDG_CACHE_HOME"/direnv/layouts/
                  echo -n "$PWD" | shasum | cut -d ' ' -f 1
              )}"
          }
        '';
      };
    };
  };
}
