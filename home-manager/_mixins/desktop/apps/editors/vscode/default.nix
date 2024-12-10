{ inputs, lib, pkgs, username, config, ... }:
let
  installFor = [ "juca" ];
  inherit (pkgs.stdenv) isLinux;
  inherit (lib) mkIf mkEnableOption;
  nixgl = import ../../../../../../lib/nixGL.nix { inherit config pkgs; };
  isGeneric = if (config.targets.genericLinux.enable) then true else false;
  cfg = config.desktop.apps.editors.vscode;

  settings-directory = if pkgs.stdenv.hostPlatform.isDarwin then "$HOME/Library/Application Support/Code/User" else "$HOME/.config/Code/User";
  defaultExtensions = { "remote.SSH.defaultExtensions" = map (x: x.vscodeExtUniqueId) extensions; };
  userSettings = (builtins.fromJSON (builtins.readFile ./settings.json)) // defaultExtensions;
  keybindings = builtins.fromJSON (builtins.readFile ./keybindings.json);
  extensions = import ./extensions.nix { inherit pkgs; };
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
      ];

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
    };
    programs = {
      vscode = {
        enable = true;
        mutableExtensionsDir = true;
        inherit extensions userSettings keybindings;
        package = if (isGeneric) then (nixgl pkgs.unstable.vscode) else pkgs.unstable.vscode;
        enableUpdateCheck = false;
        enableExtensionUpdateCheck = false;
      };
    };
  };
}
